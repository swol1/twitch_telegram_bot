# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    sequence(:telegram_id)
    locale { 'en' }
  end
end
