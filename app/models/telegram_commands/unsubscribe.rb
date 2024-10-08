# frozen_string_literal: true

module TelegramCommands
  class Unsubscribe < Base
    def execute
      text = unsubscribe_chat_from_streamer
      send_message(text:)
    end

    private

    def login = @args

    def unsubscribe_chat_from_streamer
      if chat.unsubscribe_from(login)
        I18n.t('streamer_subscription.unsubscribed', login:)
      else
        I18n.t('errors.chat_not_subscribed', login:)
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      App.logger.log_error(e, 'Streamer Not Destroyed')
      I18n.t('errors.generic')
    end
  end
end
