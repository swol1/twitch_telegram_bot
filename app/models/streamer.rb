# frozen_string_literal: true

class Streamer < ActiveRecord::Base
  include ChannelInfo, EventSubscriptions

  has_many :chat_streamer_subscriptions, dependent: :destroy
  has_many :subscribers, through: :chat_streamer_subscriptions, source: :chat

  validates :login, presence: true, uniqueness: true
  validates :name, presence: true
  validates :twitch_id, presence: true, uniqueness: true
  validates :telegram_login, uniqueness: true, allow_blank: true

  default_scope { order('LOWER(name)') }

  class << self
    def find_or_create_from_twitch(login)
      find_by(login:) || create_from_twitch!(login)
    end

    def create_from_twitch!(login)
      Streamer::Twitch::Data.new(login).create_streamer!.tap do |streamer|
        streamer.update_channel_info_from_twitch
        streamer.subscribe_to_twitch_events
      end
    end
  end

  def info = Streamer::Info.new(self)
end
