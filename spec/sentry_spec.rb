# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sentry do
  it 'sends error to Sentry when logs error' do
    allow(Sentry).to receive(:initialized?).and_return(true)
    allow(Sentry).to receive(:capture_message)
    App.logger.log_error(nil, 'Some error')

    expect(Sentry).to have_received(:capture_message).with("Error caught: \nMsg: Some error")
  end
end
