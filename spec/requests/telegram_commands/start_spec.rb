# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/start command' do
    let(:message_text) { '/start' }

    it 'sends welcome message' do
      expected_text = <<~TEXT.strip
        Hi there, John Doe! 👋

        🚀 You can subscribe to streamers and receive notifications, when they go live, switch categories, or change titles. Remember, you can follow up to 2 streamers simultaneously. Enjoy the experience!

        <code>sub streamer_login</code> - subscribe to <i>streamer_login</i> notifications
        <code>unsub streamer_login</code> - unsubscribe from <i>streamer_login</i> notifications
        <code>unsub_all</code> - unsubscribe from all notifications

        Replace <i>streamer_login</i> with the actual streamer's login. The login can be found in the URL on Twitch.
        Example: <code>sub twitch</code>

        /list - list of your subscriptions with the latest streamer’s information
      TEXT
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      post '/telegram/webhook', message_params.to_json, headers
    end
  end
end
