# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe 'POST /telegram/webhook' do
    let(:invalid_headers) do
      { 'CONTENT_TYPE' => 'application/json', 'HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN' => 'wrong_token' }
    end
    let(:message_text) { '/start' }

    context 'with invalid token' do
      it 'does not send message' do
        post '/telegram/webhook', message_params.to_json, invalid_headers

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq('error' => 'Invalid token')
        expect(telegram_bot_client).not_to have_received(:send_message)
      end

      it 'doesn\'t create user' do
        expect { post '/telegram/webhook', message_params.to_json, invalid_headers }.not_to(change { User.count })
      end
    end

    context 'with valid params' do
      it 'creates user' do
        updated_message_params = message_params.deep_merge(
          message: {
            from: { id: 123_456_789 },
            chat: { id: 123_456_789 }
          }
        )
        expect { post '/telegram/webhook', updated_message_params.to_json, headers }.to change { User.count }.by(1)
      end
    end

    context 'with chat member status' do
      let(:chat_member_params) do
        {
          update_id: 123_456_789,
          my_chat_member: {
            chat: { id: 123_456_789 },
            new_chat_member: { status: 'kicked' }
          }
        }
      end

      it 'removes user if kicked' do
        create(:user, chat_id: 123_456_789)
        expect { post '/telegram/webhook', chat_member_params.to_json, headers }.to change { User.count }.by(-1)
      end

      it 'does not remove user if not kicked' do
        chat_member_params[:my_chat_member][:new_chat_member][:status] = 'member'
        create(:user, chat_id: 123_456_789)
        expect { post '/telegram/webhook', chat_member_params.to_json, headers }.not_to(change { User.count })
      end
    end
  end
end
