# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    sequence(:telegram_id)
    locale { 'en' }
    just_chatting_mode { false }
  end
end
