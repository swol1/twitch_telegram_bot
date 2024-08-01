# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/list command' do
    let(:message_text) { '/list' }

    subject(:send_webhook_request) { post '/telegram/webhook', message_params.to_json, headers }

    context 'when user has no subscriptions' do
      it 'doesn\'t send message' do
        expected_text = I18n.t('streamer_subscription.info.not_subscribed')

        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        send_webhook_request
      end
    end

    context 'when user has subscriptions but no streamers info' do
      it 'sends a message indicating no subscriptions' do
        streamers = 1.upto(2).map do |i|
          create(:streamer, login: "streamer_login_#{i}", name: "Streamer #{i}", twitch_id: i.to_s)
        end
        user.subscriptions << streamers

        expected_text = <<~TEXT.strip
          You are subscribed to: <b>streamer_login_1</b>, <b>streamer_login_2</b>

          Data is not available yet 😢
        TEXT
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        send_webhook_request
      end
    end

    context 'when user has subscriptions and info' do
      it 'sends a message listing the subscriptions and their info' do
        streamers = 1.upto(3).map do |i|
          create(:streamer, login: "streamer_login_#{i}", name: "Streamer #{i}", twitch_id: i.to_s)
        end

        user.subscriptions << streamers
        streamers[0].channel_info.update(title: 'Some Title', category: 'Some Category', status: 'Offline')
        streamers[1].channel_info.update(title: '', status: '')
        streamers[2].channel_info.update(title: 'Some Title t.me/my_login', status: 'online')
        streamers[2].set_telegram_login_from_title

        expected_text = <<~TEXT.strip
          You are subscribed to: <b>streamer_login_1</b>, <b>streamer_login_2</b>, <b>streamer_login_3</b>

          <b>Streamer 1</b> 🔴
          Category: Some Category
          Title: Some Title
          twitch: https://twitch.tv/streamer_login_1

          <b>Streamer 3</b> 🟢
          Title: Some Title t.me/my_login
          twitch: https://twitch.tv/streamer_login_3
          telegram: https://t.me/my_login
        TEXT
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        send_webhook_request
      end
    end
  end
end
