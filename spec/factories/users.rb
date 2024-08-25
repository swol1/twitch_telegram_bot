# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:chat_id)
    locale { 'en' }
  end
end
