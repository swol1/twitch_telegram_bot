# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'IgnoreBadRequestsMiddleware', type: :request do
  it 'returns a 404 Not Found and does not trigger Sentry' do
    expect(Sentry).not_to receive(:capture_message)
    expect(Sentry).not_to receive(:capture_exception)

    post '/index.htm'

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq('bb')
  end
end
