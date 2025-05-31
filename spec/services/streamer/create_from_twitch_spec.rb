# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::CreateFromTwitch, type: :service do
  let(:login) { 'test_login' }
  let(:streamer_data) { { login: 'test_login', id: 'twitch_123', display_name: 'Test Streamer' } }

  subject { -> { described_class.call(login) } }

  before do
    allow(twitch_api_client).to receive(:get_streamer)
      .with('test_login')
      .and_return(success_response(data: [streamer_data]))
    allow(Streamer::UpdateInfo).to receive(:call)
  end

  context 'when streamer data is found' do
    it 'creates a new streamer record with correct attributes' do
      expect { subject.call }.to change { Streamer.count }.by(1)
      created_streamer = Streamer.last
      expect(created_streamer.login).to eq('test_login')
      expect(created_streamer.twitch_id).to eq('twitch_123')
      expect(created_streamer.name).to eq('Test Streamer')
    end

    it 'calls the update info service and enqueues the appropriate jobs' do
      created_streamer = subject.call

      expect(Streamer::UpdateInfo).to have_received(:call).with(created_streamer)
      expect(Streamer::SubscribeToTwitchEventsJob).to have_enqueued_sidekiq_job(created_streamer.id)
      expect(Streamer::ReconcileEnabledTwitchEventsJob).to have_enqueued_sidekiq_job(created_streamer.id).in(10.minutes)
    end
  end

  context 'when streamer data is not found' do
    it 'does not create a streamer and raises NotFoundError' do
      allow(twitch_api_client).to receive(:get_streamer).with(login).and_return(not_found_response)

      expect { subject.call }.to raise_error(Streamer::CreateFromTwitch::NotFoundError)
        .and(not_change { Streamer.count })
      expect(Streamer::SubscribeToTwitchEventsJob).not_to have_enqueued_sidekiq_job
      expect(Streamer::ReconcileEnabledTwitchEventsJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when streamer already exists' do
    let!(:streamer) { create(:streamer, login: 'old_login', twitch_id: 'twitch_123', name: 'Old Name') }

    it 'updates the existing streamer attributes without enqueuing jobs' do
      updated_data = { login: 'new_login', id: 'twitch_123', display_name: 'New Name' }
      allow(twitch_api_client).to receive(:get_streamer).with(login)
                                                        .and_return(success_response(data: [updated_data]))
      allow(Streamer::UpdateInfo).to receive(:call)

      result = subject.call

      expect(result.id).to eq(streamer.id)
      expect(streamer.reload.login).to eq('new_login')
      expect(streamer.reload.name).to eq('New Name')
      expect(Streamer::UpdateInfo).not_to have_received(:call)
      expect(Streamer::SubscribeToTwitchEventsJob).not_to have_enqueued_sidekiq_job
      expect(Streamer::ReconcileEnabledTwitchEventsJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when streamer.save! fails' do
    let!(:streamer) { create(:streamer, streamer_data.tap { _1.delete(:display_name) }) }

    it 'raises an ActiveRecord::RecordInvalid error and does not enqueue any jobs' do
      allow(streamer).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Streamer.new))

      expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Streamer::UpdateInfo).not_to have_received(:call)
      expect(Streamer::SubscribeToTwitchEventsJob).not_to have_enqueued_sidekiq_job
      expect(Streamer::ReconcileEnabledTwitchEventsJob).not_to have_enqueued_sidekiq_job
    end
  end
end
