# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::ActivatingEventsOnTwitchJob, type: :job do
  let(:streamer) { create(:streamer) }

  context 'when there are inactive events' do
    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_return(success_response(message: 'subscription already exists'))
    end

    it 'activates inactive events' do
      expect { described_class.new.perform(streamer.id) }
        .to change { streamer.event_subscriptions.inactive.reload.count }.from(3).to(0)
        .and change { streamer.event_subscriptions.active.count }.from(0).to(3)
    end

    it 'does not change active events' do
      streamer.event_subscriptions.each(&:active!)

      expect { described_class.new.perform(streamer.id) }
        .not_to(change { streamer.event_subscriptions.active.count })
    end
  end

  context 'when twitch subscription does not already exist' do
    before do
      allow(twitch_api_client).to receive(:subscribe_to_event)
        .and_return(success_response)
    end

    it 'does not activate the event' do
      expect { described_class.new.perform(streamer.id) }
        .not_to(change { streamer.event_subscriptions.active.count })
    end
  end

  context 'when streamer is not found' do
    it 'raises an ActiveRecord::RecordNotFound error' do
      expect { described_class.new.perform(-1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
