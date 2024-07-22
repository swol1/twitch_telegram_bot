# frozen_string_literal: true

module TwitchEvents
  class StreamOnline < Base
    def process
      return if status_unchanged?

      update_streamer_info
      notify_subscribers(text: text_with_locales)
    end

    private

    def update_streamer_info = channel_info[:status] = 'online'
    def status_unchanged? = channel_info[:status] == 'online'

    def text_with_locales
      name = streamer.info.name_with_emoji
      I18n.with_all_locales do
        I18n.t('streamer_notification.online', name:)
      end
    end
  end
end
