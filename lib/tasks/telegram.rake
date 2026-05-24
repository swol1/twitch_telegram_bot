# frozen_string_literal: true

namespace :telegram do
  desc 'Set Telegram bot command menu'
  task set_commands: :environment do
    telegram_api = Telegram::Bot::Client.new(App.secrets.telegram_token).api

    { en: nil, ru: 'ru' }.each do |locale, language_code|
      params = { commands: I18n.t('telegram_bot.commands', locale:) }
      params[:language_code] = language_code if language_code

      telegram_api.set_my_commands(params)

      puts "Set #{locale.upcase} Telegram bot commands."
    end
  end
end
