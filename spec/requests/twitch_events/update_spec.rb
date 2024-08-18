# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:params) do
    base_params.deep_merge(
      event: {
        category_name: 'some_category',
        title: 'some_title t.me/my_tg_login'
      }
    )
  end
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'channel.update') }

  subject(:send_webhook_request) { post '/twitch/eventsub', params.to_json, headers }

  describe 'POST channel.update event' do
    context 'when values changed' do
      before { streamer.channel_info.update(title: 'title', category: 'category') }

      it 'updates streamer data' do
        expect { send_webhook_request }
          .to change { streamer.reload.telegram_login }.from(nil).to('my_tg_login')
          .and change { streamer.channel_info[:title] }.from('title').to('some_title t.me/my_tg_login')
          .and change { streamer.channel_info[:category] }.from('category').to('some_category')
      end

      it 'notifies subscribers' do
        users = create_list(:user, 3, subscriptions: [streamer])

        expected_text = <<~TEXT.strip
          <b>Streamer Name</b> 😀
          Category: some_category
          Title: some_title t.me/my_tg_login
        TEXT
        expect(telegram_bot_client).to receive_send_message_with(
          {
            text: expected_text,
            reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
              inline_keyboard: [[
                Telegram::Bot::Types::InlineKeyboardButton.new(
                  text: 'Twitch', url: 'https://twitch.tv/streamer_login'
                ),
                Telegram::Bot::Types::InlineKeyboardButton.new(
                  text: 'Telegram', url: 'https://t.me/my_tg_login'
                )
              ]]
            )
          }
        ).to_users(users)

        send_webhook_request

        expect(last_response.status).to eq(204)
      end
    end

    context 'when values the same' do
      before { streamer.channel_info.update(title: 'some_title t.me/my_tg_login', category: 'some_category') }

      it 'doesn\'t update streamer data' do
        expect { send_webhook_request }
          .to not_change { streamer.reload.telegram_login }
          .and not_change { streamer.channel_info[:title] }
          .and(not_change { streamer.channel_info[:category] })
      end

      it 'doesn\'t notify users' do
        send_webhook_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end

    context 'when telegram login already set' do
      it "doesn't update telegram login" do
        streamer.update(telegram_login: 'other_login')
        expect { send_webhook_request }.to change { streamer.reload.telegram_login }
          .from('other_login')
          .to('my_tg_login')
      end
    end
  end
end
