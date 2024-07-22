# frozen_string_literal: true

RSpec.shared_context 'with stubbed telegram bot client' do
  let(:telegram_bot_client) { instance_double('TelegramBotClient') }

  before do
    allow(TelegramBotClient).to receive(:new).and_return(telegram_bot_client)
    allow(telegram_bot_client).to receive(:send_message)
  end
end
