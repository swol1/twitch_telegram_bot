# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSubscription, type: :model do
  describe 'validations' do
    subject { create(:event_subscription) }

    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_inclusion_of(:event_type).in_array(EventSubscription::TYPES.keys) }
    it do
      is_expected.to validate_uniqueness_of(:event_type)
        .scoped_to(:streamer_twitch_id)
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
end
