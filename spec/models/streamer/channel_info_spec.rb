# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::ChannelInfo, type: :model do
  let!(:streamer) { create(:streamer, :with_enabled_subscriptions) }

  describe '#expire_channel_info' do
    it 'sets the expiration for channel info' do
      expect(Kredis.redis).to receive(:expire).with(streamer.channel_info.key, Streamer::ChannelInfo::STREAMER_ID_TTL)
      streamer.channel_info.update(title: 'title')
    end
  end

  describe '#set_telegram_login_from_title' do
    it 'sets the telegram login if present in the title' do
      streamer.channel_info[:title] = 'Check out my channel at t.me/test_telegram'
      streamer.set_telegram_login_from_title
      expect(streamer.telegram_login).to eq('test_telegram')
    end

    it 'does not change telegram login if title does not match' do
      streamer.channel_info[:title] = 'Check out my channel at https://some_url.me/test_telegram'
      streamer.set_telegram_login_from_title
      expect(streamer.telegram_login).to eq(nil)
    end

    it 'does not change telegram login if already set' do
      streamer.update(telegram_login: 'existing_login')
      streamer.channel_info[:title] = 't.me/test_telegram'
      streamer.set_telegram_login_from_title
      expect(streamer.telegram_login).to eq('test_telegram')
    end

    it 'does not change telegram login if title nil' do
      streamer.update(telegram_login: 'existing_login')
      streamer.channel_info[:title] = nil
      streamer.set_telegram_login_from_title
      expect(streamer.telegram_login).to eq('existing_login')
    end
  end
end
