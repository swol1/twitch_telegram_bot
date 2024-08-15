# frozen_string_literal: true

module Streamer::ChannelInfo
  extend ActiveSupport::Concern

  STREAMER_ID_TTL = 96 * 60 * 60
  TELEGRAM_REGEX = %r{t\.me/([a-zA-Z0-9_]+)}

  included do
    kredis_hash :channel_info,
                key: ->(s) { "streamer_id:#{s.twitch_id}" },
                after_change: lambda(&:expire_channel_info)
  end

  def update_channel_info_from_twitch
    Streamer::Twitch::ChannelInfo.new(self).update_streamer_channel_info
  end

  def expire_channel_info
    Kredis.redis.expire(channel_info.key, STREAMER_ID_TTL)
  end

  def set_telegram_login_from_title
    return unless (title = channel_info[:title])

    telegram_login = title[TELEGRAM_REGEX, 1]
    update(telegram_login:) if telegram_login
  end
end
