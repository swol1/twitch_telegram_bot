# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchEvent::ProcessJob, type: :job do
  let(:params) do
    {
      id: '123',
      type: 'stream.online',
      twitch_id: 'twitch_1',
      name: 'Streamer Name',
      login: 'streamer_login',
      category: 'some_category',
      title: 'some_title',
      received_at: Time.current.iso8601
    }
  end
  let!(:streamer) { create(:streamer, twitch_id: 'twitch_1') }
  let(:service) { instance_double('TwitchEvents::StreamOnline') }

  before do
    allow(TwitchEvents::StreamOnline).to receive(:new).and_return(service)
    allow(service).to receive(:process)
  end

  describe '#perform' do
    context 'when the event is valid and not duplicated' do
      it 'process the event' do
        expect(TwitchEvents::StreamOnline).to receive(:new).with(instance_of(TwitchEvent))
        expect(service).to receive(:process)

        described_class.new.perform(params)
      end
    end

    context 'when the event is not valid' do
      let(:invalid_params) { params.merge(id: nil) }

      it 'does not process the event and logs an error' do
        expect(TwitchEvents::StreamOnline).not_to receive(:new)
        expect(service).not_to receive(:process)
        expect(App.logger).to receive(:log_error).with(
          nil,
          a_string_matching(/valid: false, not_duplicated: true/)
        )

        described_class.new.perform(invalid_params)
      end
    end

    context 'when the event is duplicated' do
      it 'does not process the event and logs an error' do
        TwitchEvent.new(params).received.mark

        expect(TwitchEvents::StreamOnline).not_to receive(:new)
        expect(service).not_to receive(:process)
        expect(App.logger).to receive(:log_error).with(
          nil,
          a_string_matching(/valid: true, not_duplicated: false/)
        )

        described_class.new.perform(params)
      end
    end

    context 'when incorrect status event order' do
      it 'does not process the even' do
        streamer.channel_info[:status_received_at] = (Time.current + 1.second).iso8601

        expect(TwitchEvents::StreamOnline).not_to receive(:new)
        expect(service).not_to receive(:process)
        expect(App.logger).to receive(:log_error).with(
          nil,
          a_string_matching(/valid: false, not_duplicated: true/)
        )

        described_class.new.perform(params)
      end
    end
  end
end
