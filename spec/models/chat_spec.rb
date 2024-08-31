# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chat, type: :model do
  describe 'validations' do
    before do
      create(:chat, { telegram_id: 'abc123', locale: 'en' })
    end

    it { is_expected.to validate_presence_of(:telegram_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_id) }
  end

  describe 'callbacks' do
    it 'sets the locale to "en" before creation if locale is not available' do
      chat = Chat.new(telegram_id: '67890')
      expect(chat.locale).to be_nil
      chat.save
      expect(chat.locale).to eq('en')
    end

    it 'does not override a valid locale' do
      chat = Chat.new(telegram_id: '67890', locale: 'ru')
      chat.save
      expect(chat.locale).to eq('ru')
    end
  end

  describe 'encryption' do
    it 'encrypts telegram_id before saving' do
      chat = Chat.create(telegram_id: 12_345, locale: 'en')
      encrypted_telegram_id = ActiveRecord::Base.connection.execute(
        "select telegram_id from chats where id = #{chat.id}"
      ).first['telegram_id']

      expect(encrypted_telegram_id).not_to eq('12345')
      expect(encrypted_telegram_id).to be_a(String)
      expect(encrypted_telegram_id).to include('"p":')
    end

    it 'decrypts telegram_id correctly after saving' do
      chat = Chat.create(telegram_id: '12345', locale: 'en')
      expect(chat.telegram_id).to eq('12345')
    end
  end

  describe 'Subscriber module methods' do
    let(:chat) { create(:chat) }
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }

    describe '#unsubscribe_from' do
      it 'removes a subscription by streamer login' do
        chat.subscriptions << streamer
        expect { chat.unsubscribe_from(streamer.login) }.to change { chat.subscriptions.count }.by(-1)
      end

      it 'does nothing if the streamer is not found' do
        chat.subscriptions << streamer
        expect { chat.unsubscribe_from('nonexistent') }.not_to(change { chat.subscriptions.count })
      end

      it 'does nothing if subscription is not found' do
        expect { chat.unsubscribe_from(streamer.login) }.not_to(change { chat.subscriptions.count })
      end
    end
  end
end
