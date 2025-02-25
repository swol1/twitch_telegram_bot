# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::ReconcileEnabledTwitchEventsJob, type: :job do
  let(:streamer) { create(:streamer, :with_pending_subscriptions) }

  context 'when there are pending events' do
    it 'enqueues SubscribeToTwitchEventsJob and raises error' do
      expect { described_class.new.perform(streamer.id) }
        .to enqueue_sidekiq_job(Streamer::SubscribeToTwitchEventsJob).with(streamer.id)
        .and raise_error(PendingEventsError)
    end
  end

  context 'when there are no pending events' do
    before do
      streamer.event_subscriptions.each(&:enabled!)
    end

    it 'does not enqueue SubscribeToTwitchEventsJob' do
      expect { described_class.new.perform(streamer.id) }
        .not_to enqueue_sidekiq_job(Streamer::SubscribeToTwitchEventsJob)
    end

    it 'does not raise PendingEventsError' do
      expect { described_class.new.perform(streamer.id) }.not_to raise_error
    end
  end
end
