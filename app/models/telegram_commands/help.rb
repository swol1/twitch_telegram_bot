# frozen_string_literal: true

module TelegramCommands
  class Help < Base
    def execute
      text = I18n.t('help_message', instructions: I18n.t('common_instructions'))
      send_message(text:)
    end
  end
end
