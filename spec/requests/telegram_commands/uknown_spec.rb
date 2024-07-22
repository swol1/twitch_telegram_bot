# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe 'unknown command' do
    let(:message_text) { '/gibberish command' }

    it 'sends help command message' do
      expected_text = I18n.t('help_message', instructions: I18n.t('common_instructions'))
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

      post '/telegram/webhook', message_params.to_json, headers
    end
  end
end
