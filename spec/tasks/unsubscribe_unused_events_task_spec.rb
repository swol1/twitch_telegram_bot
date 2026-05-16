# frozen_string_literal: true

require 'spec_helper'
require 'rake'

RSpec.describe 'unsubscribe_unused_events task' do
  include_context 'with stubbed twitch api client'

  before(:all) do
    custom_rake_path = File.expand_path('../../lib/tasks', __dir__)
    Rake.application.rake_require('unsubscribe_unused_events', [custom_rake_path])
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task['unsubscribe_unused_events'] }

  before { task.reenable }

  it 'deletes remote Twitch subscriptions that do not exist locally' do
    allow(twitch_api_client).to receive(:get_all_app_subscriptions).and_return(
      success_response(data: [{ id: 'remote_subscription_id', status: 'enabled' }])
    )

    expect(twitch_api_client).to receive(:delete_subscription_to_event)
      .with('remote_subscription_id')
      .once
      .and_return({ status: '204', body: {} })

    expect { task.invoke }.to output(
      a_string_including(
        'Successfully unsubscribed from twitch event for subscription remote_subscription_id.',
        'Unsubscribed from 1 unused twitch events.'
      )
    ).to_stdout
  end

  it 'skips remote Twitch subscriptions that exist locally' do
    event_subscription = create(:event_subscription)
    allow(twitch_api_client).to receive(:get_all_app_subscriptions).and_return(
      success_response(data: [{ id: event_subscription.twitch_id, status: 'enabled' }])
    )

    expect(twitch_api_client).not_to receive(:delete_subscription_to_event)

    expect { task.invoke }.to output("Unsubscribed from 0 unused twitch events.\n").to_stdout
  end

  it 'skips remote Twitch subscriptions that are pending verification' do
    allow(twitch_api_client).to receive(:get_all_app_subscriptions).and_return(
      success_response(data: [{ id: 'remote_subscription_id', status: 'webhook_callback_verification_pending' }])
    )

    expect(twitch_api_client).not_to receive(:delete_subscription_to_event)

    expect { task.invoke }.to output("Unsubscribed from 0 unused twitch events.\n").to_stdout
  end
end
