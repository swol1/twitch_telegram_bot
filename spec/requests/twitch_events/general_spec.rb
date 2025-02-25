# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  describe 'POST /twitch/eventsub' do
    let(:params) do
      base_params.deep_merge(
        event: {
          category_name: 'some_category',
          title: 'some_title'
        }
      )
    end
    let(:streamer) { create(:streamer, :with_pending_subscriptions) }
    let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'channel.update') }

    subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

    context 'when webhook_callback_verification' do
      let(:message_type) { 'webhook_callback_verification' }
      let(:params) do
        {
          challenge: 'pogchamp-kappa-360noscope-vohiyo',
          subscription: {
            id: event_subscription.twitch_id,
            type: 'channel.update',
            version: '2',
            condition: {
              broadcaster_user_id: streamer.twitch_id
            }
          }
        }
      end

      it 'verifies the subscription and returns the challenge' do
        expect { send_request }
          .to change { event_subscription.reload.status }.from('pending').to('enabled')

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(params[:challenge])
      end
    end

    context 'when revocation' do
      let(:message_type) { 'revocation' }

      it 'sets the event subscription to revoked' do
        event_subscription.enabled!

        expect { send_request }.to change { event_subscription.reload.status }.from('enabled').to('revoked')
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

    context 'when the event subscription does not exist' do
      let(:message_type) { 'notification' }

      it 'returns a 422 status' do
        allow(HandleTwitchEventJob).to receive(:perform_async)
        event_subscription.destroy

        send_request

        expect(last_response.status).to eq(422)
        expect(last_response.body).to include('Invalid event subscription')
        expect(HandleTwitchEventJob).not_to have_received(:perform_async)
      end
    end

    context 'when an error occurs' do
      let(:message_type) { 'notification' }

      it 'returns a 500 status and logs the error' do
        allow(HandleTwitchEventJob).to receive(:perform_async).and_raise(StandardError.new('test error'))

        expect(App.logger).to receive(:log_error).with(instance_of(StandardError), 'Twitch webhook error')

        send_request

        expect(last_response.status).to eq(500)
        expect(last_response.body).to include('Internal server error')
      end
    end
  end
end
