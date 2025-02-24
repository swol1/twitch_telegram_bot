# frozen_string_literal: true

class Chat < ActiveRecord::Base
  has_many :chat_streamer_subscriptions, dependent: :destroy
  has_many :subscriptions, through: :chat_streamer_subscriptions, source: :streamer

  scope :without_just_chatting_mode, -> { where(just_chatting_mode: false) }

  validates :telegram_id, presence: true, uniqueness: true
  encrypts :telegram_id, deterministic: true

  before_create ->(chat) { chat.locale = 'en' unless I18n.available_locales.include?(chat.locale&.to_sym) }

  def self.max_chats_reached? = Chat.count >= App.secrets.max_chats
  def just_chatting_status = just_chatting_mode ? 'on' : 'off'
  def subscribed_to?(streamer_id) = subscriptions.exists?(streamer_id)
  def max_subscriptions_reached? = subscriptions.count >= App.secrets.max_chat_subscriptions
  def left_subscriptions = App.secrets.max_chat_subscriptions - subscriptions.count
end
