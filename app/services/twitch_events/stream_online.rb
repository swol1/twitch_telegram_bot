# frozen_string_literal: true

module TwitchEvents
  class StreamOnline < Base
    def call
      update_channel_info
      notify_subscribers(text: text_with_locales) unless stream_restarted?
    end

    private

    def stream_restarted?
      @twitch_event.secs_since_prev_status_event < 60
    end

    def update_channel_info
      channel_info[:status] = 'online'
      channel_info[:status_received_at] = @twitch_event.received_at
      Kredis.redis.persist(streamer.name_with_emoji.key)
    end

    def text_with_locales
      I18n.with_all_locales do
        I18n.t('streamer_notification.online', streamer_name:)
      end
    end
  end
end
