# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::UpdateInfo, type: :service do
  let(:streamer) { create(:streamer) }

  subject { -> { described_class.call(streamer) } }

  before do
    streamer.channel_info.update(category: '', title: '')
    allow(twitch_api_client).to receive(:get_channel_info).with(streamer.twitch_id).and_return(
      success_response(data: [{ game_name: 'Music', title: 'Live Now' }])
    )
  end

  context 'when channel_info already has a title' do
    it 'returns early' do
      streamer.channel_info.update(title: 'Existing Title')

      result = subject.call
      expect(result).to be_nil
      expect(streamer.channel_info[:title]).to eq('Existing Title')
      expect(twitch_api_client).not_to have_received(:get_channel_info)
    end
  end

  context 'when channel_info is empty and Twitch API returns valid data' do
    it 'updates channel_info with the fetched data' do
      expect(streamer).to receive(:set_telegram_login_from_title)
      subject.call
      expect(streamer.channel_info[:title]).to eq('Live Now')
      expect(streamer.channel_info[:category]).to eq('Music')
    end
  end

  context 'when Twitch API returns a non-200 status' do
    it 'returns early' do
      allow(twitch_api_client).to receive(:get_channel_info).and_return({ status: '404' })

      result = subject.call
      expect(result).to be_nil
      expect(streamer.channel_info.to_h).to eq('category' => '', 'title' => '')
    end
  end
end
