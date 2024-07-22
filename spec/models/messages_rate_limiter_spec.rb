# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramMessagesRateLimiter do
  let(:chat_id) { '123' }
  let(:rate_limiter) { TelegramMessagesRateLimiter.new(3) }

  describe '#wait_if_limits_exceeded' do
    it 'waits if total messages limit is exceeded' do
      expect(rate_limiter).to receive(:sleep).with(0.1).at_least(:once)

      3.times { rate_limiter.wait_if_limits_exceeded(SecureRandom.uuid) }
      sleep 0.9
      rate_limiter.wait_if_limits_exceeded(SecureRandom.uuid)
    end

    it 'waits if chat messages limit is exceeded' do
      expect(rate_limiter).to receive(:sleep).with(0.1).at_least(:once)

      rate_limiter.wait_if_limits_exceeded(chat_id)
      sleep 0.9
      rate_limiter.wait_if_limits_exceeded(chat_id)
    end

    it 'does not wait if limits are not exceeded' do
      expect(rate_limiter).not_to receive(:sleep)

      rate_limiter.wait_if_limits_exceeded(chat_id)
    end
  end
end
