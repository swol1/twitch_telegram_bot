# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLoggerMiddleware::FilteredRequestHeaders do
  describe '#parameters' do
    let(:request) do
      Rack::Request.new(
        Rack::MockRequest.env_for(
          '/twitch/eventsub',
          'HTTP_TWITCH_EVENTSUB_MESSAGE_ID' => 'message-id',
          'HTTP_TWITCH_EVENTSUB_MESSAGE_SIGNATURE' => 'sha256=twitch-signature',
          'HTTP_TWITCH_EVENTSUB_MESSAGE_TIMESTAMP' => '2026-05-16T15:00:00Z',
          'HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN' => 'telegram-secret'
        )
      )
    end

    it 'redacts webhook secret headers' do
      headers = described_class.new.parameters(request, nil).fetch(:headers)

      expect(headers).to include(
        'Twitch-Eventsub-Message-Signature' => '[FILTERED]',
        'X-Telegram-Bot-Api-Secret-Token' => '[FILTERED]',
        'Twitch-Eventsub-Message-Id' => 'message-id',
        'Twitch-Eventsub-Message-Timestamp' => '2026-05-16T15:00:00Z'
      )
      expect(headers.values).not_to include(
        'sha256=twitch-signature',
        'telegram-secret'
      )
    end
  end
end
