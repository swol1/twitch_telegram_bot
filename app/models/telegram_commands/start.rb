# frozen_string_literal: true

module TelegramCommands
  class Start < Base
    def execute
      full_name = "#{@from&.first_name} #{@from&.last_name}".presence || 'user'
      text = I18n.t('hello_message',
                    name: full_name,
                    max_subs: User::Subscriber::MAX_SUBSCRIPTIONS,
                    instructions: I18n.t('common_instructions'))
      send_message(text:)
    end
  end
end
