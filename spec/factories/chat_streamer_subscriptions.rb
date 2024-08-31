# frozen_string_literal: true

FactoryBot.define do
  factory :chat_streamer_subscription do
    chat
    streamer
  end
end
