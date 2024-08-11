# frozen_string_literal: true

FactoryBot.define do
  factory :twitch_event do
    id { '1' }
    type { 'channel.update' }
    twitch_id { 't123' }
    name { 'test' }
    login { 'test_login' }
    received_at { Time.current.iso8601 }
  end
end
