# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::SubscribeToTwitchEvents, type: :service do
  let(:streamer) { create(:streamer) }

  subject { -> { described_class.call(streamer) } }

  before do
    allow(Streamer::SubscribeToTwitchEventsJob).to receive(:perform_async)
    allow(Streamer::ReconcileEnabledTwitchEventsJob).to receive(:perform_in)
  end

  context 'when streamer has all event types enabled' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }

    it 'returns early and does not call the external API' do
      result = subject.call
      expect(result).to be_nil
      expect(twitch_api_client).not_to have_received(:subscribe_to_event)
    end
  end

  context 'when there are pending events' do
    let(:streamer) { create(:streamer, :with_pending_subscriptions) }

    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_return(success_response(message: 'subscription already exists'))
    end

    it 'enables pending events' do
      expect { subject.call }
        .to change { streamer.event_subscriptions.pending.reload.count }.from(3).to(0)
        .and change { streamer.event_subscriptions.enabled.reload.count }.from(0).to(3)
    end
  end

  context 'when there are no pending events' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }

    it 'does nothing' do
      expect(twitch_api_client).not_to receive(:subscribe_to_event)
      subject.call
    end
  end

  context 'when event subscriptions are successfully created' do
    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_return(
          success_response(data: [{ id: SecureRandom.uuid }]),
          success_response(data: [{ id: SecureRandom.uuid }]),
          success_response(data: [{ id: SecureRandom.uuid }])
        )
    end

    it 'creates event subscriptions' do
      expect { subject.call }.to change { streamer.event_subscriptions.pending.count }.from(0).to(3)
    end
  end

  context 'when the Twitch API client raises an error' do
    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_raise(StandardError.new('API error'))
    end

    it 'raises the error and does not create any subscriptions' do
      expect { subject.call }.to raise_error(StandardError, 'API error')
      expect(streamer.event_subscriptions.count).to eq(0)
    end
  end

  context 'when an event subscription cannot be created' do
    before do
      allow(twitch_api_client).to receive(:subscribe_to_event).and_return(not_found_response)
    end

    it 'raises EventSubscriptionNotCreatedError' do
      expect { subject.call }.to raise_error(EventSubscriptionNotCreatedError)
    end
  end
end
