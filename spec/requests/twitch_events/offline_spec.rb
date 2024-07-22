# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:streamer) { create(:streamer, :with_active_subscriptions, name: 'Streamer Name', twitch_id: '123456') }
  let(:params) do
    {
      subscription: {
        id: 'test_subscription_id',
        type: 'stream.offline',
        condition: {
          broadcaster_user_id: '123456'
        }
      },
      event: {
        broadcaster_user_id: '123456',
        broadcaster_user_login: 'streamer_login',
        broadcaster_user_name: 'Streamer Name'
      }
    }
  end

  subject(:send_webhook_request) { post '/twitch/eventsub', params.to_json, headers }

  around do |ex|
    Sidekiq::Testing.inline! { ex.run }
  end

  describe 'POST channel.offline event' do
    context 'when status changed' do
      before { streamer.channel_info[:status] = 'online' }

      it 'updates streamer data' do
        expect { send_webhook_request }
          .to change { streamer.channel_info[:status] }.from('online').to('offline')
      end

      it 'it doesn\'t notify users' do
        send_webhook_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end

    context 'when status the same' do
      before { streamer.channel_info[:status] = 'offline' }

      it 'doesn\'t update streamer data' do
        expect { send_webhook_request }
          .not_to(change { streamer.channel_info[:status] })
      end

      it 'doesn\'t notify users' do
        send_webhook_request

        expect(telegram_bot_client).not_to have_received(:send_message)
        expect(last_response.status).to eq(204)
      end
    end
  end
end
