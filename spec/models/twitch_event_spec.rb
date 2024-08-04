# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchEvent, type: :model do
  let!(:twitch_event) { build(:twitch_event) }

  subject { twitch_event }

  before do
    create(:streamer, twitch_id: twitch_event.twitch_id)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:id) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:twitch_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_presence_of(:received_at) }

    it do
      is_expected.to validate_inclusion_of(:type).in_array(EventSubscription::TYPES.keys)
    end
  end

  describe '#not_duplicated?' do
    it 'marks the event as received with an expiration' do
      expect(twitch_event.not_duplicated?).to eq(true)
      expect(twitch_event.not_duplicated?).to eq(false)
    end
  end

  describe '#correct_status_event_order' do
    context 'when received_at is after the previous status event time' do
      it 'is valid' do
        twitch_event.type = 'stream.offline'
        twitch_event.received_at = Time.current.iso8601
        expect(twitch_event).to be_valid
      end
    end

    context 'when received_at is before the previous status event time' do
      it 'is not valid' do
        twitch_event.type = 'stream.online'
        twitch_event.received_at = 2.days.ago.iso8601
        expect(twitch_event).not_to be_valid
        expect(twitch_event.errors[:base]).to include('Incorrect status order')
      end
    end
  end
end
