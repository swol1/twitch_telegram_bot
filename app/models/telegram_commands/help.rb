# frozen_string_literal: true

module TelegramCommands
  class Help < Base
    def execute
      text = I18n.t(
        'help_message',
        instructions: I18n.t('common_instructions'),
        just_chatting_status: chat.just_chatting_status
      )
      send_message(text:)
    end
  end
end
