# frozen_string_literal: true

require 'spec_helper'
require 'rake'

RSpec.describe 'destroy_unused_streamers task' do
  include_context 'with stubbed twitch api client'

  before(:all) do
    custom_rake_path = File.expand_path('../../rake', __dir__)
    Rake.application.rake_require('destroy_unused_streamers', [custom_rake_path])
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task['destroy_unused_streamers'] }
  let!(:streamer) { create(:streamer, :with_enabled_subscriptions) }
  let(:streamer_twitch_id) { streamer.twitch_id }

  before { task.reenable }

  context 'when a streamer has pending event subscriptions' do
    it 'logs an error and does not destroy the streamer' do
      streamer.event_subscriptions.first.update!(status: EventSubscription.statuses[:pending])

      expect(App.logger).to receive(:log_error)
        .with(nil, a_string_including("Streamer #{streamer.id} was not destroyed: pending event subscriptions exist"))
      expect { task.invoke }.not_to(change { Streamer.count })
      expect(EventSubscription.where(streamer_twitch_id:).count).to eq(3)
    end
  end

  context 'when a streamer has enabled event subscriptions' do
    it 'destroys the streamer and event subscriptions and calls the external API' do
      streamer.event_subscriptions.each do |subscription|
        expect(twitch_api_client).to receive(:delete_subscription_to_event)
          .with(subscription.twitch_id).once
      end

      expect { task.invoke }
        .to change { Streamer.count }.by(-1)
        .and change { EventSubscription.where(streamer_twitch_id:).count }.from(3).to(0)
    end
  end

  context 'when all event subscriptions are revoked' do
    it 'destroys the streamer and event subscriptions without calling the external API' do
      streamer.event_subscriptions.update_all(status: EventSubscription.statuses[:revoked])

      expect(twitch_api_client).not_to receive(:delete_subscription_to_event)
      expect { task.invoke }
        .to change { Streamer.count }.by(-1)
        .and change { EventSubscription.where(streamer_twitch_id:).count }.from(3).to(0)
    end
  end
end
