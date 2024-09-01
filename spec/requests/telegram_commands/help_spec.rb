# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  let(:message_text) { '/help' }

  describe '/help command' do
    it 'sends help message' do
      expected_text = I18n.t('help_message', instructions: I18n.t('common_instructions'))
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      post '/telegram/webhook', message_params.to_json, headers
    end
  end
end
