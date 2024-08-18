# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::EventSubscriptions, type: :model do
  let!(:streamer) { create(:streamer, :with_enabled_subscriptions) }

  context 'when valid for destroy' do
    it 'unsubscribes from twitch events' do
      twitch_ids = streamer.event_subscriptions.pluck(:twitch_id)
      expect { streamer.destroy }
        .to enqueue_sidekiq_job(Streamer::UnsubscribingFromTwitchEventsJob).with(twitch_ids)
    end

    it 'destroys streamer and event subscriptions' do
      expect { streamer.destroy }
        .to change { Streamer.count }.by(-1)
        .and change { EventSubscription.count }.from(3).to(0)
    end
  end

  context 'when all subscriptions are revoked' do
    before { streamer.event_subscriptions.update_all(status: :revoked) }

    it 'destroys streamer and event subscriptions' do
      expect { streamer.destroy }
        .to change { Streamer.count }.by(-1)
        .and change { EventSubscription.count }.from(3).to(0)
    end

    it 'does not enqueue UnsubscribingFromTwitchEventsJob' do
      expect { streamer.destroy }
        .not_to enqueue_sidekiq_job(Streamer::UnsubscribingFromTwitchEventsJob)
    end
  end

  RSpec.shared_examples 'does not destroy streamer or subscriptions' do
    it 'does not destroy streamer or event subscriptions' do
      expect { streamer.destroy }
        .to not_change(Streamer, :count)
        .and not_change(EventSubscription, :count)
    end

    it 'does not enqueue UnsubscribingFromTwitchEventsJob' do
      expect { streamer.destroy }
        .not_to enqueue_sidekiq_job(Streamer::UnsubscribingFromTwitchEventsJob)
    end
  end

  context 'when there are pending subscriptions' do
    before { streamer.event_subscriptions.first.update(status: :pending) }

    it_behaves_like 'does not destroy streamer or subscriptions'
  end

  context 'when there are not exactly 3 subscriptions' do
    before { streamer.event_subscriptions.first.destroy }

    it_behaves_like 'does not destroy streamer or subscriptions'
  end
end
