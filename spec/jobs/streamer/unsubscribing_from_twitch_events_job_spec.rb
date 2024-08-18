# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::UnsubscribingFromTwitchEventsJob, type: :job do
  let(:streamer) { create(:streamer, :with_enabled_subscriptions) }
  let(:twitch_ids) { streamer.event_subscriptions.pluck(:twitch_id) }

  it 'unsubscribes from twitch' do
    allow(twitch_api_client).to receive(:delete_subscription_to_event).and_return({ status: '204' })

    described_class.new.perform(twitch_ids)

    streamer.event_subscriptions.each do |subscription|
      expect(twitch_api_client).to have_received(:delete_subscription_to_event).with(subscription.twitch_id)
    end
  end

  it 'logs an error for any non-204 or 404 response for any subscription' do
    allow(twitch_api_client).to receive(:delete_subscription_to_event).and_return({ status: '500' })
    allow(App.logger).to receive(:log_error)

    described_class.new.perform(twitch_ids)

    twitch_ids.each do |twitch_id|
      expected_message = "Subscription was not deleted: #{twitch_id}. Response: {:status=>\"500\"}"
      expect(App.logger).to have_received(:log_error).with(nil, expected_message)
    end
  end
end
