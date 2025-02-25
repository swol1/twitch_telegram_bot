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
end
