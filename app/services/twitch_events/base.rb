# frozen_string_literal: true

module TwitchEvents
  class Base < BaseService
    def initialize(event)
      @event = event
      @telegram_bot_client = TelegramBotClient.new
    end

    def call
      raise NotImplementedError, "#{self.class} must implement the 'call' method"
    end

    private

    def streamer = @event.streamer
    def subscribers = streamer.subscribers
    def channel_info = @_channel_info ||= streamer.channel_info

    def notify_subscribers(text:)
      keyboard = Streamer::TelegramKeyboardPresenter.new(streamer).social_links_keyboard
      subscribers.each do |subscriber|
        @telegram_bot_client.send_message(
          chat_id: subscriber.telegram_id,
          text: text[subscriber.locale],
          reply_markup: keyboard,
          disable_web_page_preview: true,
          parse_mode: :html
        )
      end
    end
  end
end
