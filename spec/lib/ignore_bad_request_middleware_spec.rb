# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'IgnoreBadRequestsMiddleware', type: :request do
  def app = IgnoreBadRequestsMiddleware.new(Root)

  it 'returns a 404 Not Found and does not trigger Sentry' do
    expect(Sentry).not_to receive(:capture_message)
    expect(Sentry).not_to receive(:capture_exception)

    post '/index.htm'

    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq('Not Found')
  end

  it 'ignores malformed root multipart probes' do
    env = Rack::MockRequest.env_for(
      '/',
      method: 'POST',
      input: '',
      'CONTENT_LENGTH' => '249',
      'CONTENT_TYPE' => 'multipart/form-data; boundary=----WebKitFormBoundaryx8jO2oVc6SWP3Sad'
    )

    response = nil
    expect { response = app.call(env) }.not_to raise_error

    expect(response[0]).to eq(404)
    expect(response[2]).to eq(['Not Found'])
  end
end
