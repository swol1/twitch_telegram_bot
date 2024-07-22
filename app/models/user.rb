# frozen_string_literal: true

class User < ActiveRecord::Base
  include Subscriber

  validates :telegram_id, presence: true, uniqueness: true
  validates :chat_id, presence: true, uniqueness: true

  before_create ->(user) { user.locale = 'en' unless I18n.available_locales.include?(user.locale&.to_sym) }
end
