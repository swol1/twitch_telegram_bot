# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:params) { base_params }
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'stream.online') }
  let(:stream_restart_threshold) { App.secrets.stream_restart_threshold_seconds.to_i.seconds }

  subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

  before { allow(TwitchEvents::DeliverNotificationJob).to receive(:perform_in) }

  describe 'POST stream.online event' do
    context 'when status changed' do
      before do
        streamer.channel_info[:status_received_at] = (Time.current - stream_restart_threshold - 1.second).iso8601
        streamer.channel_info[:status] = 'offline'
      end

      it 'updates streamer data and removes name_with_emoji expiration' do
        streamer.name_with_emoji.value = 'Test 🎉'
        Kredis.redis.expire(streamer.name_with_emoji.key, 2.hours)
        expect(Kredis.redis.ttl(streamer.name_with_emoji.key)).to be > 0

        expect { send_request }
          .to change { streamer.channel_info[:status] }.from('offline').to('online')

        expect(Kredis.redis.ttl(streamer.name_with_emoji.key)).to eq(-1)
      end

      it 'notifies subscribers' do
        chats = create_list(:chat, 3, subscriptions: [streamer])

        send_request

        expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in).exactly(chats.size).times
        chats.each do |chat|
          expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in)
            .with(0, chat.id, streamer.id, 'stream.online', {})
        end
        expect(last_response.status).to eq(204)
      end
    end

    context 'when stream restarted' do
      before do
        streamer.channel_info[:status_received_at] = (Time.current - stream_restart_threshold + 1.second).iso8601
        streamer.channel_info[:status] = 'offline'
      end

      it 'updates streamer data' do
        expect { send_request }
          .to change { streamer.channel_info[:status] }.from('offline').to('online')
      end

      it 'doesn\'t send message to chats' do
        send_request

        expect(TwitchEvents::DeliverNotificationJob).not_to have_received(:perform_in)
        expect(last_response.status).to eq(204)
      end
    end
  end
end
