# frozen_string_literal: true

module TelegramCommands
  class Unsubscribe < Base
    def call
      text = unsubscribe_chat_from_streamer
      send_message(text:)
    end

    private

    def login = @args

    def unsubscribe_chat_from_streamer
      streamer = Streamer.find_by(login:)
      chat_streamer_subscription = chat.chat_streamer_subscriptions.find_by(streamer_id: streamer&.id)
      return I18n.t('errors.chat_not_subscribed', login:) unless streamer && chat_streamer_subscription

      chat_streamer_subscription.destroy
      I18n.t('streamer_subscription.unsubscribed', login:)
    end
  end
end
