# frozen_string_literal: true

FactoryBot.define do
  factory :twitch_event do
    id { '1' }
    type { 'channel.update' }
    twitch_id { SecureRandom.uuid }
    received_at { Time.current.iso8601 }
  end
end
