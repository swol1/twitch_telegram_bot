# frozen_string_literal: true

class Streamer::TelegramKeyboardPresenter
  def initialize(streamer)
    @streamer = streamer
  end

  def social_links_keyboard
    buttons = [twitch_button]
    buttons << telegram_button if @streamer.telegram_login.present?
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [buttons])
  end

  private

  def twitch_button
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: 'Twitch',
      url: "https://twitch.tv/#{@streamer.login}"
    )
  end

  def telegram_button
    Telegram::Bot::Types::InlineKeyboardButton.new(
      text: 'Telegram',
      url: "https://t.me/#{@streamer.telegram_login}"
    )
  end
end
