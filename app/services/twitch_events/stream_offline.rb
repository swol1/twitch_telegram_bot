# frozen_string_literal: true

module TwitchEvents
  class StreamOffline < Base
    def call
      channel_info[:status] = 'offline'
      channel_info[:status_received_at] = @twitch_event.received_at
      Kredis.redis.expire(streamer.name_with_emoji.key, 4.hours)
    end
  end
end
