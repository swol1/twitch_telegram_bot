# frozen_string_literal: true

module TwitchEvents
  class StreamOnline < Base
    def call
      if stream_restarted?
        update_channel_info
      else
        update_channel_info
        notify_subscribers(text: text_with_locales)
      end
    end

    private

    def stream_restarted?
      @event.secs_since_prev_status_event < 30
    end

    def update_channel_info
      channel_info[:status] = 'online'
      channel_info[:status_received_at] = @event.received_at
    end

    def text_with_locales
      name = Streamer::InfoPresenter.new(streamer).name_with_emoji
      I18n.with_all_locales do
        I18n.t('streamer_notification.online', name:)
      end
    end
  end
end
