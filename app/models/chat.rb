# frozen_string_literal: true

class Chat < ActiveRecord::Base
  include Subscriber

  validates :telegram_id, presence: true, uniqueness: true
  encrypts :telegram_id, deterministic: true

  before_create ->(chat) { chat.locale = 'en' unless I18n.available_locales.include?(chat.locale&.to_sym) }

  def self.max_chats_reached? = Chat.count >= App.secrets.max_chats
  def just_chatting_status = just_chatting_mode ? 'on' : 'off'
end
