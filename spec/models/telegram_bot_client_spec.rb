# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramBotClient do
  let(:telegram_token) { 'fake_token' }
  let(:api) { double('Telegram::Bot::Api') }
  let(:rate_limiter) { instance_double(TelegramMessagesRateLimiter) }
  let(:client) { described_class.new }

  before do
    allow(App.secrets).to receive(:telegram_token).and_return(telegram_token)
    allow(Telegram::Bot::Client).to receive(:new).with(telegram_token).and_return(double(api:))
    allow(TelegramMessagesRateLimiter).to receive(:new).and_return(rate_limiter)
    allow(rate_limiter).to receive(:wait_if_limits_exceeded)
    allow(api).to receive(:send_message)
  end

  describe '#send_message' do
    it 'sends a message through the API' do
      message = { chat_id: '123', text: 'Hello' }

      client.send_message(message)

      expect(rate_limiter).to have_received(:wait_if_limits_exceeded).with('123')
      expect(api).to have_received(:send_message).with(message)
    end

    it 'logs an error if sending fails' do
      message = { chat_id: '123', text: 'Hello' }

      allow(api).to receive(:send_message).and_raise(StandardError, 'API error')

      expect(App.logger).to receive(:log_error).with(
        instance_of(StandardError),
        'Delivery failure message: Hello to user 123: API error'
      )

      client.send_message(message)
    end

    context 'when a Telegram::Bot::Exceptions::ResponseError is raised' do
      it 'destroys the user and logs the error' do
        user = create(:user, chat_id: '123')
        message = { chat_id: '123', text: 'Hello' }
        response = instance_double('Response', body: { 'error_code' => 403 }.to_json, status: 403)
        error = Telegram::Bot::Exceptions::ResponseError.new(response:)
        allow(api).to receive(:send_message).with(message).and_raise(error)

        expect(App.logger).to receive(:log_error)
          .with(error, "Caught specific Telegram exception. User: #{user.inspect}")

        expect { client.send_message(message) }.to change { User.count }.by(-1)
      end
    end
  end
end
