# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:params) { base_params }
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'stream.offline') }

  subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

  describe 'POST channel.offline event' do
    context 'when status changed' do
      before { streamer.channel_info[:status] = 'online' }

      it 'updates streamer data' do
        expect { send_request }
          .to change { streamer.channel_info[:status] }.from('online').to('offline')
      end

      it 'it doesn\'t notify chats' do
        send_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end

    context 'when status the same' do
      before { streamer.channel_info[:status] = 'offline' }

      it 'doesn\'t update streamer data' do
        expect { send_request }.not_to(change { streamer.channel_info[:status] })
      end

      it 'doesn\'t notify chats' do
        send_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end
  end
end
