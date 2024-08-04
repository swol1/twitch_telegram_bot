# frozen_string_literal: true

module TwitchEvents
  class StreamOnline < Base
    def process
      if stream_restarted?
        update_channel_info
      else
        update_channel_info
        notify_subscribers(text: text_with_locales)
      end
    end

    private

    def stream_restarted?
      @event.seconds_since_last_event < 60
    end

    def update_channel_info
      channel_info[:status] = 'online'
      channel_info[:created_at] = @event.created_at
    end

    def text_with_locales
      name = streamer.info.name_with_emoji
      I18n.with_all_locales do
        I18n.t('streamer_notification.online', name:)
      end
    end
  end
end
