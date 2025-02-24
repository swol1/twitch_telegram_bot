# frozen_string_literal: true

module TelegramCommands
  class ToggleJustChattingMode < Base
    def call
      chat.toggle!(:just_chatting_mode)
      text = chat.just_chatting_mode ? I18n.t('just_chatting_mode_on') : I18n.t('just_chatting_mode_off')
      send_message(text:)
    end
  end
end
