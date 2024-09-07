# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  let(:message_text) { '/toggle_just_chatting_mode' }

  subject(:send_webhook_request) { post '/telegram/webhook', message_params.to_json, headers }

  describe '/toggle_just_chatting_mode command' do
    it 'toggles just chatting mode on' do
      expected_text = I18n.t('just_chatting_mode_on')
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      expect { send_webhook_request }.to change { chat.reload.just_chatting_mode }.from(false).to(true)
    end

    it 'toggles just chatting mode off' do
      chat.toggle!(:just_chatting_mode)
      expected_text = I18n.t('just_chatting_mode_off')
      expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

      expect { send_webhook_request }.to change { chat.reload.just_chatting_mode }.from(true).to(false)
    end
  end
end
