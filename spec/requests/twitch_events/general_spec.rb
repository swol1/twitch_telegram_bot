# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  describe 'POST /twitch/eventsub' do
    let(:subscription) do
      create(
        :event_subscription,
        streamer_twitch_id: '123456',
        event_type: 'channel.update',
        version: '2',
        status: :inactive
      )
    end

    subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

    context 'when webhook_callback_verification' do
      let(:message_type) { 'webhook_callback_verification' }

      it 'verifies the subscription and returns the challenge' do
        params = {
          challenge: 'pogchamp-kappa-360noscope-vohiyo',
          subscription: {
            id: 'f1c2a387-161a-49f9-a165-0f21d7a4e1c4',
            status: 'webhook_callback_verification_pending',
            type: 'channel.update',
            version: '2',
            cost: 1,
            condition: {
              broadcaster_user_id: subscription.streamer_twitch_id
            },
            transport: {
              method: 'webhook',
              callback: 'https://example.com/webhooks/callback'
            },
            created_at: '2019-11-16T10:11:12.634234626Z'
          }
        }

        expect { post '/twitch/eventsub', params.to_json, headers }
          .to change { subscription.reload.status }.from('inactive').to('active')

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(params[:challenge])
      end
    end

    context 'when revocation' do
      let(:message_type) { 'revocation' }

      it 'sets the subscription to inactive' do
        subscription.active!

        expect { send_request }.to change { subscription.reload.status }.from('active').to('inactive')
        expect(last_response.status).to eq(204)
      end
    end

    context 'when the signature is invalid' do
      let(:message_type) { 'notification' }

      it 'returns a 403 status' do
        allow(OpenSSL::HMAC).to receive(:hexdigest).and_return('invalid_signature')

        send_request

        expect(last_response.status).to eq(403)
        expect(last_response.body).to include('Invalid signature')
      end
    end

    context 'when the message type is invalid' do
      let(:message_type) { 'some_type' }

      it 'returns a 204 status' do
        send_request

        expect(last_response.status).to eq(204)
      end
    end

    context 'when an error occurs' do
      let(:message_type) { 'notification' }

      it 'returns a 500 status and logs the error' do
        allow(TwitchEvent::ProcessJob).to receive(:perform_async).and_raise(StandardError.new('test error'))

        expect(App.logger).to receive(:log_error).with(instance_of(StandardError), 'Twitch webhook error')

        post '/twitch/eventsub', params.to_json, headers

        expect(last_response.status).to eq(500)
        expect(last_response.body).to include('Internal server error')
      end
    end
  end
end
