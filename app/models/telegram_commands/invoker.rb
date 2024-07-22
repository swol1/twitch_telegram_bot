# frozen_string_literal: true

module TelegramCommands
  class Invoker
    COMMANDS = {
      'start' => 'Start',
      'help' => 'Help',
      'sub' => 'Subscribe',
      'unsub' => 'Unsubscribe',
      'unsub_all' => 'UnsubscribeAll',
      'list' => 'List'
    }.freeze

    def initialize(message)
      @message = message
    end

    def execute
      command, args = parse_message_text
      command_class = COMMANDS.fetch(command, 'Help')

      "TelegramCommands::#{command_class}".constantize.new(@message.from, @message.chat, args).execute
    end

    private

    def parse_message_text
      command, args = @message.text.downcase.split(' ', 2)
      command = command&.delete_prefix('/')
      [command, args]
    end
  end
end
