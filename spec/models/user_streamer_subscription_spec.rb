# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserStreamerSubscription, type: :model do
  describe 'validations' do
    it 'validates uniqueness of user_id scoped to streamer_id' do
      user = create(:user)
      streamer = create(:streamer)
      create(:user_streamer_subscription, user:, streamer:)

      duplicate_subscription = build(:user_streamer_subscription, user:, streamer:)
      expect(duplicate_subscription).not_to be_valid
    end
  end

  describe 'after_destroy callback' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    context 'when the streamer has no more subscribers' do
      it 'destroys the streamer' do
        create(:user_streamer_subscription, user: user1, streamer:)

        expect { UserStreamerSubscription.find_by(user: user1, streamer:).destroy }
          .to change { Streamer.exists?(streamer.id) }.from(true).to(false)
      end
    end

    context 'when the streamer still has other subscribers' do
      it 'does not destroy the streamer' do
        create(:user_streamer_subscription, user: user1, streamer:)
        create(:user_streamer_subscription, user: user2, streamer:)

        expect { UserStreamerSubscription.find_by(user: user1, streamer:).destroy }
          .not_to(change { Streamer.exists?(streamer.id) })
      end
    end
  end
end
