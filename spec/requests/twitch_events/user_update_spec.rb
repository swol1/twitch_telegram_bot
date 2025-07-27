# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:new_login) { 'new_login' }
  let(:new_name)  { 'New Name' }
  let(:params) do
    base_params.deep_merge(
      event: {
        user_name: new_name,
        user_login: new_login
      }
    )
  end
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'user.update') }

  subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

  describe 'POST user.update event' do
    context 'when user info changed' do
      before { streamer.update!(login: 'old_login', name: 'Old Name') }

      it 'updates streamer login and name' do
        expect { send_request }
          .to change { streamer.reload.login }.from('old_login').to(new_login)
          .and change { streamer.reload.name }.from('Old Name').to(new_name)
      end

      it 'notifies subscribers' do
        chats = create_list(:chat, 3, subscriptions: [streamer])
        expected_text = <<~TEXT.strip
          Old Name has changed their information:
          Login: new_login
          Name: New Name
        TEXT

        expect(telegram_bot_client).to receive_send_message_with(
          {
            text: expected_text,
            reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
              inline_keyboard: [[
                Telegram::Bot::Types::InlineKeyboardButton.new(
                  text: 'Twitch',
                  url: "https://twitch.tv/#{new_login}"
                )
              ]]
            )
          }
        ).to_chats(chats)

        send_request
        expect(last_response.status).to eq(204)
      end
    end
  end
end
