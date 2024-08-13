# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RateLimiter do
  describe '.check' do
    let(:limiter) { instance_double(Kredis::Limiter, poke: true) }

    before do
      allow(Kredis).to receive(:limiter).and_return(limiter)
    end

    context 'when the rate limit is exceeded' do
      it 'sleeps until the limit is no longer exceeded' do
        allow(limiter).to receive(:exceeded?).and_return(true, true, false)

        expect(RateLimiter).to receive(:sleep).with(0.1).twice

        RateLimiter.check('rate_limit:key', limit: 5)
      end
    end

    context 'when the rate limit is not exceeded' do
      it 'does not sleep and pokes the limiter' do
        allow(limiter).to receive(:exceeded?).and_return(false)

        expect(RateLimiter).not_to receive(:sleep)
        expect(limiter).to receive(:poke)

        RateLimiter.check('rate_limit:key', limit: 5)
      end
    end
  end
end
