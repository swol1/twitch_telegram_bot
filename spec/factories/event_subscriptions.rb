# frozen_string_literal: true

FactoryBot.define do
  factory :event_subscription do
    sequence(:streamer_twitch_id) { |n| "twitch_#{n}" }
    event_type { 'channel.update' }
    version { '2' }
    status { :pending }
    twitch_id { SecureRandom.uuid }
  end
end
