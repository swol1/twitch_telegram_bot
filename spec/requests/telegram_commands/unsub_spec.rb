# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/unsub some_streamer command' do
    let(:message_text) { '/unsub some_streamer' }

    context 'when subscribed to streamer' do
      it 'unsubscribes from streamer' do
        streamer = create(:streamer, :with_enabled_subscriptions, login: 'some_streamer')
        chat.subscriptions << streamer

        expected_text = I18n.t('streamer_subscription.unsubscribed', login: streamer.login)
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to change { chat.subscriptions.reload.count }.from(1).to(0)
      end
    end

    context 'when chat has no subscriptions' do
      it 'returns a chat not subscribed error' do
        create(:streamer, :with_enabled_subscriptions, login: 'some_streamer')
        expected_text = I18n.t('errors.chat_not_subscribed', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to(not_change { chat.subscriptions.reload.count })
      end
    end

    context 'when streamer does not exist' do
      it 'returns a streamer not found error' do
        expected_text = I18n.t('errors.chat_not_subscribed', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to(not_change { chat.subscriptions.reload.count })
      end
    end
  end
end
