# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSubscription, type: :model do
  describe 'validations' do
    subject { create(:event_subscription) }

    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_inclusion_of(:event_type).in_array(EventSubscription::TYPES.keys) }
    it do
      is_expected.to validate_uniqueness_of(:event_type).scoped_to(:streamer_twitch_id)
                                                        .with_message('should be unique per streamer')
    end
    it { is_expected.to validate_presence_of(:streamer_twitch_id) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[pending enabled revoked]) }

    it 'has pending as the default value for status' do
      event_subscription = EventSubscription.new
      expect(event_subscription.status).to eq('pending')
    end
  end

  describe 'unsubscribe from Twitch before destroy' do
    let(:twitch_api_client) { instance_double(TwitchApiClient) }
    let(:event_subscription) { create(:event_subscription, status: :enabled) }

    before do
      allow(TwitchApiClient).to receive(:new).and_return(twitch_api_client)
    end

    context 'when the subscription is not revoked' do
      it 'calls the Twitch API to unsubscribe' do
        expect(twitch_api_client).to receive(:delete_subscription_to_event)
          .with(event_subscription.twitch_id)
          .and_return({ status: '204' })

        event_subscription.destroy
      end

      it 'logs an error if the API response is not 204 or 404' do
        allow(twitch_api_client).to receive(:delete_subscription_to_event).and_return({ status: '500' })
        expect(App.logger).to receive(:log_error).with(nil, /Subscription was not deleted/)

        event_subscription.destroy
      end
    end

    context 'when the subscription is revoked' do
      it 'does not call the Twitch API' do
        event_subscription.update(status: :revoked)
        expect(twitch_api_client).not_to receive(:delete_subscription_to_event)

        event_subscription.destroy
      end
    end
  end
end
