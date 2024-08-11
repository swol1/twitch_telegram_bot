# frozen_string_literal: true

RSpec.shared_context 'with default twitch setup' do
  let(:streamer) do
    create(
      :streamer,
      :with_enabled_subscriptions,
      login: 'streamer_login',
      name: 'Streamer Name',
      twitch_id: '123456'
    )
  end
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'stream.online') }
  let(:message_type) { 'notification' }
  let(:headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_ID' => 'test_message_id',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_TIMESTAMP' => Time.current.iso8601,
      'HTTP_TWITCH_EVENTSUB_MESSAGE_SIGNATURE' => 'sha256=test_signature',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_TYPE' => message_type
    }
  end
  let(:base_params) do
    {
      subscription: {
        id: event_subscription.twitch_id,
        type: event_subscription.event_type,
        version: event_subscription.version,
        condition: { broadcaster_user_id: streamer.twitch_id }
      },
      event: {}
    }
  end

  before do
    allow(App.secrets).to receive(:twitch_message_secret).and_return('test_secret')
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('test_signature')
  end
end
