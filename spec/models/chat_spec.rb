# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chat, type: :model do
  describe 'validations' do
    before { create(:chat, { telegram_id: 'abc123', locale: 'en' }) }

    it { is_expected.to validate_presence_of(:telegram_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_id) }
  end

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
