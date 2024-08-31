# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/unsub_all command' do
    let(:message_text) { '/unsub_all' }

    it 'unsubscribes from all streamers' do
      %w[some_streamer some_streamer_2].each do |login|
        streamer = create(:streamer, login:)
        chat.subscribe_to(streamer)
      end

      expected_text = I18n.t('streamer_subscription.unsubscribed_all')
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      expect { post '/telegram/webhook', message_params.to_json, headers }
        .to change { chat.subscriptions.reload.count }.from(2).to(0)
    end
  end
end
