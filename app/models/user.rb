# frozen_string_literal: true

class User < ActiveRecord::Base
  include Subscriber

  validates :chat_id, presence: true, uniqueness: true
  encrypts :chat_id, deterministic: true

  before_create ->(user) { user.locale = 'en' unless I18n.available_locales.include?(user.locale&.to_sym) }

  def self.max_users_reached? = User.count >= App.secrets.max_users
end
