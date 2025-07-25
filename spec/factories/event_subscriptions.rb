# frozen_string_literal: true

FactoryBot.define do
  factory :event_subscription do
    streamer
    event_type { EventSubscription::TYPES.first }
    version { EventSubscription.config_for(event_type)[:version] }
    status    { :pending }
    twitch_id { SecureRandom.uuid }
  end
end
