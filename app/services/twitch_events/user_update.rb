# frozen_string_literal: true

module TwitchEvents
  class UserUpdate < Base
    def call
      login = @twitch_event.payload['user_login']
      name = @twitch_event.payload['user_name']

      return unless streamer
      return if login == streamer.login && name == streamer.name

      old_name = streamer.name
      streamer.update!(login:, name:)
      notify_subscribers(text: text_with_locales(old_name))
    end

    private

    def text_with_locales(old_name)
      I18n.with_all_locales do
        I18n.t('streamer_notification.info_update', old_name:, login: streamer.login, name: streamer.name)
      end
    end
  end
end
