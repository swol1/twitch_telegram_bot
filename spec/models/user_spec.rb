# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    before do
      create(:user, { telegram_id: '12345', chat_id: '67890', locale: 'en' })
    end

    it { is_expected.to validate_presence_of(:telegram_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_id) }
    it { is_expected.to validate_presence_of(:chat_id) }
    it { is_expected.to validate_uniqueness_of(:chat_id) }
  end

  describe 'callbacks' do
    it 'sets the locale to "en" before creation if locale is not available' do
      user = User.new(telegram_id: '12345', chat_id: '67890')
      expect(user.locale).to be_nil
      user.save
      expect(user.locale).to eq('en')
    end

    it 'does not override a valid locale' do
      user = User.new(telegram_id: '12345', chat_id: '67890', locale: 'ru')
      user.save
      expect(user.locale).to eq('ru')
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
