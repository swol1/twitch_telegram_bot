# frozen_string_literal: true

module TwitchEvents
  class UserUpdate < Base
    def call
      login = @twitch_event.payload['user_login']
      name = @twitch_event.payload['user_name']

      return if login == streamer.login && name == streamer.name

      old_name = streamer.name
      streamer.update!(login:, name:)
      notify_subscribers(
        notification_data: { 'old_name' => old_name, 'login' => login, 'name' => name }
      )
    end
  end
end
