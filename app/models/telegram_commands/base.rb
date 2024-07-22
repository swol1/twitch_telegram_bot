# frozen_string_literal: true

module TelegramCommands
  class Base
    def initialize(from, chat, args)
      @from = from
      @chat = chat
      @args = args
      @telegram_bot_client = TelegramBotClient.new
      set_locale
    end

    def execute
      raise NotImplementedError, "#{self.class} must implement the 'execute' method"
    end

    private

    def set_locale
      I18n.locale = user.locale
    end

    def send_message(text:)
      @telegram_bot_client.send_message(
        chat_id: user.chat_id,
        disable_web_page_preview: true,
        parse_mode: :html,
        text: text.html_safe
      )
    end

    def user
      @_user ||= User.create_with(locale: @from.language_code)
                     .find_or_create_by!(telegram_id: @from.id, chat_id: @chat.id)
    end
  end
end
