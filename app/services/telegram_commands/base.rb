# frozen_string_literal: true

module TelegramCommands
  class Base < BaseService
    def initialize(from, telegram_chat, args)
      @from = from
      @telegram_chat = telegram_chat
      @args = args
      @telegram_bot_client = TelegramBotClient.new
      I18n.locale = chat.locale
    end

    def call
      raise NotImplementedError, "#{self.class} must implement the 'call' method"
    end

    private

    def send_message(text:)
      @telegram_bot_client.send_message(
        chat_id: chat.telegram_id,
        disable_web_page_preview: true,
        parse_mode: :html,
        text:
      )
    end

    def chat
      @_chat ||= Chat.create_with(locale: @from.language_code).find_or_create_by!(telegram_id: @telegram_chat.id)
    end
  end
end
