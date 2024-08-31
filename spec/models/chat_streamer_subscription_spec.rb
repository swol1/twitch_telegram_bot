# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChatStreamerSubscription, type: :model do
  describe 'validations' do
    it 'validates uniqueness of telegram_id scoped to streamer_id' do
      chat = create(:chat)
      streamer = create(:streamer)
      create(:chat_streamer_subscription, chat:, streamer:)

      duplicate_subscription = build(:chat_streamer_subscription, chat:, streamer:)
      expect(duplicate_subscription).not_to be_valid
    end
  end

  describe 'after_destroy callback' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }
    let(:chat1) { create(:chat) }
    let(:chat2) { create(:chat) }

    context 'when the streamer has no more subscribers' do
      it 'destroys the streamer' do
        create(:chat_streamer_subscription, chat: chat1, streamer:)

        expect { ChatStreamerSubscription.find_by(chat: chat1, streamer:).destroy }
          .to change { Streamer.exists?(streamer.id) }.from(true).to(false)
      end
    end

    context 'when the streamer still has other subscribers' do
      it 'does not destroy the streamer' do
        create(:chat_streamer_subscription, chat: chat1, streamer:)
        create(:chat_streamer_subscription, chat: chat2, streamer:)

        expect { ChatStreamerSubscription.find_by(chat: chat1, streamer:).destroy }
          .not_to(change { Streamer.exists?(streamer.id) })
      end
    end
  end
end
