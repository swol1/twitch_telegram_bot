# frozen_string_literal: true

module TelegramCommands
  class UnsubscribeAll < Base
    def call
      text = unsubscribe_chat_from_all_streamers
      send_message(text:)
    end

    private

    def unsubscribe_chat_from_all_streamers
      chat.chat_streamer_subscriptions.destroy_all
      I18n.t('streamer_subscription.unsubscribed_all')
    end
  end
end
