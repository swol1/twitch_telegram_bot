# frozen_string_literal: true

class TelegramCommand::InvokeJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  COMMANDS = {
    'start' => 'Start',
    'help' => 'Help',
    'sub' => 'Subscribe',
    'unsub' => 'Unsubscribe',
    'unsub_all' => 'UnsubscribeAll',
    'list' => 'List'
  }.freeze

  def perform(params)
    message = Telegram::Bot::Types::Update.new(JSON.parse(params)).current_message
    command, args = parse_message_text(message)
    command_class = COMMANDS.fetch(command, 'Help')

    "TelegramCommands::#{command_class}".constantize.new(message.from, message.chat, args).execute
  end

  private

  def parse_message_text(message)
    command, args = message.text.downcase.split(' ', 2)
    command = command&.delete_prefix('/')
    [command, args]
  end
end
