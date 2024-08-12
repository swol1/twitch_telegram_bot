# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::SubscribingToTwitchEventsJob, type: :job do
  let(:streamer) { create(:streamer) }

  context 'when there are pending events' do
    let(:streamer) { create(:streamer, :with_pending_subscriptions) }

    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_return(success_response(message: 'subscription already exists'))
    end

    it 'enable pending events' do
      expect { described_class.new.perform(streamer.id) }
        .to change { streamer.event_subscriptions.pending.reload.count }.from(3).to(0)
        .and change { streamer.event_subscriptions.enabled.count }.from(0).to(3)
    end
  end

  context 'when there are no pending events' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }

    it 'does nothing' do
      expect(twitch_api_client).not_to receive(:subscribe_to_event)
      described_class.new.perform(streamer.id)
    end
  end

  context 'when event subscriptions are successfully created' do
    it 'creates event subscriptions' do
      allow(twitch_api_client).to receive(:subscribe_to_event).and_return(
        success_response(data: [{ id: SecureRandom.uuid }]),
        success_response(data: [{ id: SecureRandom.uuid }]),
        success_response(data: [{ id: SecureRandom.uuid }])
      )

      expect { described_class.new.perform(streamer.id) }
        .to change { streamer.event_subscriptions.pending.count }.from(0).to(3)
    end
  end

  context 'when the Twitch API client raises an error' do
    it 'raises the error and does not create a subscription' do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_raise(StandardError.new('API error'))

      expect { described_class.new.perform(streamer.id) }.to raise_error(StandardError, 'API error')
      expect(streamer.event_subscriptions.count).to eq(0)
    end
  end

  context 'when an event subscription cannot be created' do
    it 'raises EventSubscriptionNotCreatedError' do
      allow(twitch_api_client).to receive(:subscribe_to_event).and_return(not_found_response)

      expect { described_class.new.perform(streamer.id) }.to raise_error(EventSubscriptionNotCreatedError)
    end
  end

  context 'when streamer is not found' do
    it 'raises an ActiveRecord::RecordNotFound error' do
      expect { described_class.new.perform(-1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
