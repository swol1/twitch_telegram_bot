# frozen_string_literal: true

class Streamer < ActiveRecord::Base
  include ChannelInfo

  has_many :chat_streamer_subscriptions, dependent: :destroy
  has_many :subscribers, through: :chat_streamer_subscriptions, source: :chat
  has_many :event_subscriptions, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id'

  validates :login, presence: true, uniqueness: true
  validates :name, presence: true
  validates :twitch_id, presence: true, uniqueness: true
  validates :telegram_login, uniqueness: true, allow_blank: true

  kredis_string :name_with_emoji, key: ->(s) { "streamer_name:#{s.twitch_id}" }

  default_scope { order('LOWER(name)') }

  def pending_events
    event_subscriptions.pending
  end

  def enabled_events
    event_subscriptions.enabled
  end
end
