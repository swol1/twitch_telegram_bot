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

      it 'doesn\'t create chat' do
        expect { post '/telegram/webhook', message_params.to_json, invalid_headers }.not_to(change { Chat.count })
      end
    end

    context 'with valid params' do
      it 'creates chat' do
        updated_message_params = message_params.deep_merge(
          message: {
            from: { id: 123_456_789 },
            chat: { id: 123_456_789 }
          }
        )
        expect { post '/telegram/webhook', updated_message_params.to_json, headers }.to change { Chat.count }.by(1)
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

      it 'removes chat if kicked' do
        create(:chat, telegram_id: 123_456_789)
        expect { post '/telegram/webhook', chat_member_params.to_json, headers }.to change { Chat.count }.by(-1)
      end

      it 'does not remove chat if not kicked' do
        chat_member_params[:my_chat_member][:new_chat_member][:status] = 'member'
        create(:chat, telegram_id: 123_456_789)
        expect { post '/telegram/webhook', chat_member_params.to_json, headers }.not_to(change { Chat.count })
      end
    end

    context 'when max chat limit is reached' do
      before { allow(HandleTelegramCommandJob).to receive(:perform_async) }

      it 'does not invoke command and sends error response' do
        create(:chat)
        updated_message_params = message_params.deep_merge(
          message: { from: { id: 123_456_789, language_code: 'ru' }, chat: { id: 123_456_789 } }
        )

        expect(Chat.max_chats_reached?).to be_truthy

        post '/telegram/webhook', updated_message_params.to_json, headers

        expect(HandleTelegramCommandJob).not_to have_received(:perform_async)
        expect(telegram_bot_client).to have_received(:send_message)
          .with({ chat_id: 123_456_789, text: I18n.t('errors.max_chats_reached', locale: :ru) })
      end

      it 'invokes command if chat exists' do
        create(:chat)

        expect(Chat.max_chats_reached?).to be_truthy

        post '/telegram/webhook', message_params.to_json, headers

        expect(HandleTelegramCommandJob).to have_received(:perform_async)
      end
    end
  end
end
