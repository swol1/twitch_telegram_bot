# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/unsub some_streamer command' do
    let(:message_text) { '/unsub some_streamer' }

    context 'when subscribed to streamer' do
      it 'unsubscribes from streamer' do
        streamer = create(:streamer, login: 'some_streamer')
        user.subscribe_to(streamer)

        expected_text = I18n.t('streamer_subscription.unsubscribed', login: streamer.login)
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to change { user.subscriptions.reload.count }.from(1).to(0)
      end
    end

    context 'when not subscribed to streamer' do
      it 'unsubscribes from streamer' do
        expected_text = I18n.t('errors.user_not_subscribed', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .not_to(change { user.subscriptions.reload.count })
      end
    end
  end
end
