# frozen_string_literal: true

RSpec::Matchers.define :receive_send_message_with do |params|
  chain :to_users do |users|
    @expected_messages = users.map do |user|
      {
        disable_web_page_preview: true,
        parse_mode: :html,
        chat_id: user.chat_id
      }.merge!(params)
    end
  end

  match do |telegram_bot_client|
    expect(telegram_bot_client).to receive(:send_message) do |actual_message|
      expected_message = @expected_messages.find { _1[:chat_id] == actual_message[:chat_id] }
      expect(expected_message).not_to be_nil, "Expected message not found for chat_id: #{actual_message[:chat_id]}"

      expected_message.each do |key, expected_value|
        actual_value = actual_message[key]
        expect(actual_value).to eq(expected_value)
      end
    end
  end
end
