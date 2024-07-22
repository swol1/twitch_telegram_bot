# frozen_string_literal: true

RSpec.shared_context 'with default twitch setup' do
  let(:message_type) { 'notification' }
  let(:headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_ID' => 'test_message_id',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_TIMESTAMP' => Time.now.utc.to_s,
      'HTTP_TWITCH_EVENTSUB_MESSAGE_SIGNATURE' => 'sha256=test_signature',
      'HTTP_TWITCH_EVENTSUB_MESSAGE_TYPE' => message_type
    }
  end
  let(:params) do
    {
      subscription: {
        id: 'test_subscription_id',
        type: 'channel.update',
        condition: {
          broadcaster_user_id: '123456'
        }
      },
      event: {
        broadcaster_user_id: '123456',
        broadcaster_user_login: 'streamer_login',
        broadcaster_user_name: 'Streamer Name',
        category_name: 'some_category',
        title: 'some_title'
      }
    }
  end

  before do
    allow(App.secrets).to receive(:twitch_message_secret).and_return('test_secret')
    allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('test_signature')
  end
end
