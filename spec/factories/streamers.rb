# frozen_string_literal: true

FactoryBot.define do
  factory :streamer do
    sequence(:login) { |n| "streamer_login_#{n}" }
    sequence(:name) { |n| "Streamer #{n}" }
    sequence(:twitch_id) { |n| "twitch_#{n}" }
    telegram_login { nil }

    trait :with_active_subscriptions do
      after(:create) do |streamer|
        streamer.event_subscriptions.each(&:active!)
      end
    end
  end
end
