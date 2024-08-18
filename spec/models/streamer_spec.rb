# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Streamer, type: :model do
  describe 'validations' do
    subject { create(:streamer) }

    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_uniqueness_of(:login) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:twitch_id) }
    it { is_expected.to validate_uniqueness_of(:twitch_id) }
    it { is_expected.to validate_uniqueness_of(:telegram_login).allow_blank }
  end
end
