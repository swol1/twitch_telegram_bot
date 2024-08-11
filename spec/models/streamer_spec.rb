# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer, type: :model do
  let(:streamer) { create(:streamer) }

  describe 'validations' do
    subject { create(:streamer) }

    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_uniqueness_of(:login) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:twitch_id) }
    it { is_expected.to validate_uniqueness_of(:twitch_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_login).allow_blank }
  end

  describe 'ChannelInfo module' do
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
        expect(streamer.telegram_login).to eq('existing_login')
      end

      it 'does not change telegram login if title nil' do
        streamer.update(telegram_login: 'existing_login')
        streamer.channel_info[:title] = nil
        streamer.set_telegram_login_from_title
        expect(streamer.telegram_login).to eq('existing_login')
      end
    end
  end

  describe 'EventSubscription module' do
    let(:streamer) { create(:streamer, :with_enabled_subscriptions) }
    let(:twitch_api_client) { instance_double(TwitchApiClient) }

    it 'destroys dependent event subscriptions' do
      allow(TwitchApiClient).to receive(:new).and_return(twitch_api_client)
      allow(twitch_api_client).to receive(:delete_subscription_to_event).and_return({ status: '204' })

      streamer.event_subscriptions.each do |subscription|
        expect(twitch_api_client).to receive(:delete_subscription_to_event).with(subscription.twitch_id)
      end

      expect { streamer.destroy }.to change { EventSubscription.count }.by(-3)
    end
  end
end
