# frozen_string_literal: true

module TelegramCommands
  class UnsubscribeAll < Base
    def execute
      text = unsubscribe_chat_from_all_streamers
      send_message(text:)
    end

    private

    def unsubscribe_chat_from_all_streamers
      chat.unsubscribe_from_all
      I18n.t('streamer_subscription.unsubscribed_all')
    end
  end
end
