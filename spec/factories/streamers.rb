# frozen_string_literal: true

FactoryBot.define do
  factory :streamer do
    sequence(:login) { |n| "streamer_login_#{n}" }
    sequence(:name) { |n| "Streamer #{n}" }
    sequence(:twitch_id) { |n| "twitch_#{n}" }
    telegram_login { nil }

    trait :with_enabled_subscriptions do
      after(:create) do |streamer|
        EventSubscription::TYPES.each do |event_type, version|
          create(:event_subscription, streamer:, event_type:, version:, status: :enabled)
        end
      end
    end

    trait :with_pending_subscriptions do
      after(:create) do |streamer|
        EventSubscription::TYPES.each do |event_type, version|
          create(:event_subscription, streamer:, event_type:, version:)
        end
      end
    end
  end
end
