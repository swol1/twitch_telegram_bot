# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sentry do
  before do
    ENV['SENTRY_DSN'] = 'DSN'
  end

  after do
    ENV.delete('SENTRY_DSN')
  end

  it 'sends error to Sentry when logs error' do
    allow(Sentry).to receive(:capture_message)
    App.logger.log_error(nil, 'Some error')

    expect(Sentry).to have_received(:capture_message).with("Error caught: \nMsg: Some error")
  end
end
