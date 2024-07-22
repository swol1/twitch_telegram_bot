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
end
