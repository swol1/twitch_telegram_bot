# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::CheckingEventsActivationJob, type: :job do
  let(:streamer) { create(:streamer) }

  context 'when there are inactive events' do
    it 'enqueues ActivatingEventsOnTwitchJob and raises error' do
      expect { described_class.new.perform(streamer.id) }
        .to enqueue_sidekiq_job(Streamer::ActivatingEventsOnTwitchJob).with(streamer.id)
        .and raise_error(EventsInactiveError)
    end
  end

  context 'when there are no inactive events' do
    before do
      streamer.event_subscriptions.each(&:active!)
    end

    it 'does not enqueue ActivatingEventsOnTwitchJob' do
      expect { described_class.new.perform(streamer.id) }
        .not_to enqueue_sidekiq_job(Streamer::ActivatingEventsOnTwitchJob)
    end

    it 'does not raise EventsInactiveError' do
      expect { described_class.new.perform(streamer.id) }.not_to raise_error
    end
  end
end
