# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::CheckingEnabledEventsJob, type: :job do
  let(:streamer) { create(:streamer, :with_pending_subscriptions) }

  context 'when there are pending events' do
    it 'enqueues SubscribingToTwitchEventsJob and raises error' do
      expect { described_class.new.perform(streamer.id) }
        .to enqueue_sidekiq_job(Streamer::SubscribingToTwitchEventsJob).with(streamer.id)
        .and raise_error(PendingEventsError)
    end
  end

  context 'when there are no pending events' do
    before do
      streamer.event_subscriptions.each(&:enabled!)
    end

    it 'does not enqueue SubscribingToTwitchEventsJob' do
      expect { described_class.new.perform(streamer.id) }
        .not_to enqueue_sidekiq_job(Streamer::SubscribingToTwitchEventsJob)
    end

    it 'does not raise PendingEventsError' do
      expect { described_class.new.perform(streamer.id) }.not_to raise_error
    end
  end
end
