# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchEvent, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:id) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:twitch_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:login) }

    it do
      is_expected.to validate_inclusion_of(:type).in_array(EventSubscription::TYPES.keys)
    end
  end

  describe '#not_duplicated?' do
    it 'marks the event as received with an expiration' do
      twitch_event = described_class.new(
        id: '1', type: 'some_type',
        twitch_id: 't123',
        name: 'test',
        login: 'test_login'
      )
      expect(twitch_event.not_duplicated?).to eq(true)
      expect(twitch_event.not_duplicated?).to eq(false)
    end
  end
end
