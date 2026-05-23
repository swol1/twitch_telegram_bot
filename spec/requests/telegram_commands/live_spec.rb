# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/live command' do
    let(:message_text) { '/live' }

    subject(:send_request) { post '/telegram/webhook', message_params.to_json, headers }

    it 'sends only live streamers from chat subscriptions' do
      live_streamer = create(:streamer, login: 'live_login', name: 'Live Streamer', twitch_id: 'twitch_1')
      offline_streamer = create(:streamer, login: 'offline_login', name: 'Offline Streamer', twitch_id: 'twitch_2')
      another_live_streamer = create(:streamer, login: 'another_live', name: 'Another Live', twitch_id: 'twitch_3')

      chat.subscriptions << [live_streamer, offline_streamer, another_live_streamer]
      live_streamer.channel_info.update(title: 'Live Title', category: 'Live Category', status: 'online')
      offline_streamer.channel_info.update(title: 'Offline Title', category: 'Offline Category', status: 'offline')
      another_live_streamer.channel_info.update(title: 'Another Title', status: 'online')

      expected_text = <<~TEXT.strip
        Streamers live now:

        <b>Another Live</b> 🟢
        Title: Another Title
        twitch: https://twitch.tv/another_live
        unsubscribe: <code>/unsub another_live</code>

        <b>Live Streamer</b> 🟢
        Category: Live Category
        Title: Live Title
        twitch: https://twitch.tv/live_login
        unsubscribe: <code>/unsub live_login</code>
      TEXT
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      send_request
    end

    it 'sends an empty state when there are no live streamers' do
      streamer = create(:streamer)
      chat.subscriptions << streamer
      streamer.channel_info.update(status: 'offline')

      expect(telegram_bot_client)
        .to receive_send_message_with(text: 'There are no live streamers from your list.')
        .to_chats([chat])

      send_request
    end
  end
end
