# frozen_string_literal: true

FactoryBot.define do
  factory :user_streamer_subscription do
    user
    streamer
  end
end
