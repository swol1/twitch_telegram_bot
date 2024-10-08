# frozen_string_literal: true

RSpec.shared_context 'with default telegram setup' do
  let!(:chat) { create(:chat) }
  let(:headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN' => App.secrets.telegram_secret_token
    }
  end
  let(:message_params) do
    {
      update_id: 123_456,
      message: {
        message_id: 1,
        from: {
          id: SecureRandom.random_number(1_000_000),
          is_bot: false,
          first_name: 'John',
          last_name: 'Doe',
          username: 'johndoe',
          language_code: 'en'
        },
        chat: {
          id: chat.telegram_id.to_i,
          first_name: 'John',
          last_name: 'Doe',
          username: 'johndoe',
          type: 'private'
        },
        date: Time.now.to_i,
        text: message_text
      }
    }
  end
end
