# frozen_string_literal: true

module TwitchEvents
  class Base
    def initialize(event)
      @event = event
      @telegram_bot_client = TelegramBotClient.new
    end

    def process
      raise NotImplementedError, "#{self.class} must implement the 'process' method"
    end

    private

    def streamer = @event.streamer
    def subscribers = streamer.subscribers
    def channel_info = @_channel_info ||= streamer.channel_info

    def notify_subscribers(text:)
      subscribers.each do |subscriber|
        @telegram_bot_client.send_message(
          chat_id: subscriber.telegram_id,
          text: text[subscriber.locale].html_safe,
          reply_markup: social_links_keyboard,
          disable_web_page_preview: true,
          parse_mode: :html
        )
      end
    end

    def social_links_keyboard
      @_social_links_keyboard ||= begin
        buttons = [twitch_button]
        buttons << telegram_button if streamer.telegram_login.present?
        Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [buttons])
      end
    end

    def twitch_button
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: 'Twitch',
        url: "https://twitch.tv/#{streamer.login}"
      )
    end

    def telegram_button
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: 'Telegram',
        url: "https://t.me/#{streamer.telegram_login}"
      )
    end
  end
end
