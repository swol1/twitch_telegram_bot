# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchEvents::DeliverNotificationJob, type: :job do
  let(:streamer) { create(:streamer, login: 'streamer_login', name: 'Streamer Name', telegram_login: 'my_tg_login') }
  let(:subscriber) { create(:chat) }

  describe '#perform' do
    it 'delivers a stream online notification' do
      expected_text = '<b>Streamer Name</b> 😀 is online'

      described_class.new.perform(subscriber.id, streamer.id, 'stream.online')

      expect(telegram_bot_client).to have_received(:send_message).with(
        hash_including(
          chat_id: subscriber.telegram_id,
          text: expected_text,
          disable_web_page_preview: true,
          parse_mode: :html
        )
      )
    end

    it 'delivers a channel update notification' do
      notification_data = { 'category' => 'some_category', 'title' => 'some_title', 'changed_fields' => [] }
      expected_text = <<~TEXT.strip
        <b>Streamer Name</b> 😀
        Category: some_category
        Title: some_title
      TEXT

      described_class.new.perform(subscriber.id, streamer.id, 'channel.update', notification_data)

      expect(telegram_bot_client).to have_received(:send_message).with(
        hash_including(
          chat_id: subscriber.telegram_id,
          text: expected_text,
          disable_web_page_preview: true,
          parse_mode: :html
        )
      )
    end

    it 'highlights changed channel update lines' do
      notification_data = {
        'category' => 'some_category',
        'title' => 'another_title',
        'changed_fields' => ['title']
      }
      expected_text = <<~TEXT.strip
        <b>Streamer Name</b> 😀
        Category: some_category
        Title: <b>another_title</b>
      TEXT

      described_class.new.perform(subscriber.id, streamer.id, 'channel.update', notification_data)

      expect(telegram_bot_client).to have_received(:send_message)
        .with(hash_including(chat_id: subscriber.telegram_id, text: expected_text))
    end

    it 'delivers a user update notification from notification data' do
      notification_data = { 'old_name' => 'Old Name', 'login' => 'new_login', 'name' => 'New Name' }
      expected_text = <<~TEXT.strip
        Old Name has changed their information:
        Login: new_login
        Name: New Name
      TEXT

      described_class.new.perform(subscriber.id, streamer.id, 'user.update', notification_data)

      expect(telegram_bot_client).to have_received(:send_message).with(
        hash_including(chat_id: subscriber.telegram_id, text: expected_text)
      )
    end
  end
end
