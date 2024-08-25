# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    before do
      create(:user, { chat_id: 'abc123', locale: 'en' })
    end

    it { is_expected.to validate_presence_of(:chat_id) }
    it { is_expected.to validate_uniqueness_of(:chat_id) }
  end

  describe 'callbacks' do
    it 'sets the locale to "en" before creation if locale is not available' do
      user = User.new(chat_id: '67890')
      expect(user.locale).to be_nil
      user.save
      expect(user.locale).to eq('en')
    end

    it 'does not override a valid locale' do
      user = User.new(chat_id: '67890', locale: 'ru')
      user.save
      expect(user.locale).to eq('ru')
    end
  end

  describe 'encryption' do
    it 'encrypts chat_id before saving' do
      user = User.create(chat_id: 12_345, locale: 'en')
      encrypted_chat_id = ActiveRecord::Base.connection.execute(
        "select chat_id from users where id = #{user.id}"
      ).first['chat_id']

      expect(encrypted_chat_id).not_to eq('12345')
      expect(encrypted_chat_id).to be_a(String)
      expect(encrypted_chat_id).to include('"p":')
    end

    it 'decrypts chat_id correctly after saving' do
      user = User.create(chat_id: '12345', locale: 'en')
      expect(user.chat_id).to eq('12345')
    end
  end

  describe 'Subscriber module methods' do
    let(:user) { create(:user) }
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }

    describe '#unsubscribe_from' do
      it 'removes a subscription by streamer login' do
        user.subscriptions << streamer
        expect { user.unsubscribe_from(streamer.login) }.to change { user.subscriptions.count }.by(-1)
      end

      it 'does nothing if the streamer is not found' do
        user.subscriptions << streamer
        expect { user.unsubscribe_from('nonexistent') }.not_to(change { user.subscriptions.count })
      end

      it 'does nothing if subscription is not found' do
        expect { user.unsubscribe_from(streamer.login) }.not_to(change { user.subscriptions.count })
      end
    end
  end
end
