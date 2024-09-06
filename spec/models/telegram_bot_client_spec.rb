# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramBotClient do
  let(:telegram_api) { double('Telegram::Bot::Api') }
  let(:message) { { chat_id: '123', text: 'Hello!' } }
  let(:client) { described_class.new }

  before do
    allow(Telegram::Bot::Client).to receive(:new).and_return(double(api: telegram_api))
  end

  describe '#send_message' do
    it 'checks the global rate limit' do
      allow(RateLimiter).to receive(:check)
      allow(telegram_api).to receive(:send_message)

      client.send_message(message)

      expect(RateLimiter).to have_received(:check).with('rate_limit:chats', limit: 29)
    end

    it 'checks the chat rate limit' do
      allow(RateLimiter).to receive(:check)
      allow(telegram_api).to receive(:send_message)

      client.send_message(message)

      expect(RateLimiter).to have_received(:check).with("rate_limit:chat_#{message[:chat_id]}", limit: 1)
    end

    it 'sends the message after checking rate limits' do
      allow(RateLimiter).to receive(:check).and_return(nil)
      allow(telegram_api).to receive(:send_message)

      client.send_message(message)

      expect(telegram_api).to have_received(:send_message).with(message)
    end

    it 'sanitizes the message text before sending' do
      allow(RateLimiter).to receive(:check).and_return(nil)
      allow(telegram_api).to receive(:send_message)

      raw_message = { chat_id: '123', text: 'Hello <b>World</b> @user <script>alert("xss")</script>' }
      sanitized_message = { chat_id: '123',
                            text: 'Hello <b>World</b> user &lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;' }

      client.send_message(raw_message)

      expect(telegram_api).to have_received(:send_message).with(sanitized_message)
    end

    context 'when a Telegram::Bot::Exceptions::ResponseError is raised' do
      it 'destroys the chat and logs the error' do
        chat = create(:chat, telegram_id: '123')
        response = instance_double('Response', body: { 'error_code' => 403 }.to_json, status: 403)
        error = Telegram::Bot::Exceptions::ResponseError.new(response:)

        allow(RateLimiter).to receive(:check).and_return(nil)
        allow(telegram_api).to receive(:send_message).with(message).and_raise(error)

        expect(App.logger).to receive(:log_error)
          .with(error, "Caught specific Telegram exception. Chat: #{chat.inspect}")

        expect { client.send_message(message) }.to change { Chat.count }.by(-1)
      end
    end

    context 'when a StandardError is raised' do
      it 'logs the error' do
        error = StandardError.new('Some error')

        allow(RateLimiter).to receive(:check).and_return(nil)
        allow(telegram_api).to receive(:send_message).and_raise(error)

        expect(App.logger).to receive(:log_error)
          .with(error, "Delivery failure message: #{message[:text]} to chat #{message[:chat_id]}: #{error.message}")

        client.send_message(message)
      end
    end
  end
end
