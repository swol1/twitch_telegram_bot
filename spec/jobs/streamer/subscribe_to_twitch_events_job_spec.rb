# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer::SubscribeToTwitchEventsJob, type: :job do
  let(:streamer) { create(:streamer) }

  it 'calls service' do
    allow(Streamer::SubscribeToTwitchEvents).to receive(:call)
    described_class.new.perform(streamer.id)
    expect(Streamer::SubscribeToTwitchEvents).to have_received(:call).with(streamer)
  end
end
