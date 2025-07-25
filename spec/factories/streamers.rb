# frozen_string_literal: true

FactoryBot.define do
  factory :streamer do
    sequence(:login) { |n| "streamer_login_#{n}" }
    sequence(:name) { |n| "Streamer #{n}" }
    sequence(:twitch_id) { |n| "twitch_#{n}" }
    telegram_login { nil }

    trait :with_enabled_subscriptions do
      after(:create) do |streamer|
        EventSubscription::TYPES.each do |event_type|
          create(:event_subscription, streamer:, event_type:, status: :enabled)
        end
      end
    end

    trait :with_pending_subscriptions do
      after(:create) do |streamer|
        EventSubscription::TYPES.each do |event_type|
          create(:event_subscription, streamer:, event_type:)
        end
      end
    end
  end
end
