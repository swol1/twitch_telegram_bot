# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SentryTracing do
  describe '.build_transaction_name' do
    it 'builds safe transaction names' do
      examples = [
        ['/telegram/webhook', { message: { text: '/Sub streamer_login' } }, 'POST /telegram/webhook /sub'],
        ['/telegram/webhook', { message: { text: 'hello there' } }, 'POST /telegram/webhook'],
        ['/twitch/eventsub', { event: { title: 'stream title' } }, 'POST /twitch/eventsub']
      ]

      examples.each do |path, params, expected_name|
        request = instance_double(Rack::Request, request_method: 'POST', path:)

        expect(described_class.build_transaction_name(request, params)).to eq(expected_name)
      end
    end
  end
end
