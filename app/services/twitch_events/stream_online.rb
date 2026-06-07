# frozen_string_literal: true

module TwitchEvents
  class StreamOnline < Base
    def call
      restarted = stream_restarted?

      update_channel_info
      notify_subscribers unless restarted
    end

    private

    def stream_restarted?
      @twitch_event.secs_since_prev_status_event < App.secrets.stream_restart_threshold_seconds.to_i
    end

    def update_channel_info
      channel_info[:status] = 'online'
      channel_info[:status_received_at] = @twitch_event.received_at
      Kredis.redis.persist(streamer.name_with_emoji.key)
    end
  end
end
