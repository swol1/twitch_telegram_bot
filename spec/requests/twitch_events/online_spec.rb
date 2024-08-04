# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:params) { base_params }

  subject(:send_webhook_request) { post '/twitch/eventsub', params.to_json, headers }

  around do |ex|
    Sidekiq::Testing.inline! { ex.run }
  end

  describe 'POST channel.online event' do
    context 'when status changed' do
      before do
        streamer.channel_info[:status_received_at] = (Time.current - 61.seconds).iso8601
        streamer.channel_info[:status] = 'offline'
      end

      it 'updates streamer data' do
        expect { send_webhook_request }
          .to change { streamer.channel_info[:status] }.from('offline').to('online')
      end

      it 'notifies subscribers' do
        users = create_list(:user, 3, subscriptions: [streamer])

        expected_text = '<b>Streamer Name</b> 😀 is online.'
        expect(telegram_bot_client).to receive_send_message_with(
          {
            text: expected_text,
            reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
              inline_keyboard: [[
                Telegram::Bot::Types::InlineKeyboardButton.new(
                  text: 'Twitch', url: "https://twitch.tv/#{streamer.login}"
                )
              ]]
            )
          }
        ).to_users(users)

        send_webhook_request

        expect(last_response.status).to eq(204)
      end
    end

    context 'when stream restarted' do
      before do
        streamer.channel_info[:status_received_at] = (Time.current - 50.seconds).iso8601
        streamer.channel_info[:status] = 'offline'
      end

      it 'updates streamer data' do
        expect { send_webhook_request }
          .to change { streamer.channel_info[:status] }.from('offline').to('online')
      end

      it 'doesn\'t send message to users' do
        send_webhook_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end
  end
end
