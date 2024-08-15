# frozen_string_literal: true

RSpec.shared_context 'with stubbed twitch api client' do
  let(:twitch_api_client) { instance_double('TwitchApiClient') }

  before do
    allow(TwitchApiClient).to receive(:new).and_return(twitch_api_client)
    allow(twitch_api_client).to receive(:get_channel_info).and_return(success_response)
    allow(twitch_api_client).to receive(:get_streamer).and_return(success_response)
    allow(twitch_api_client).to receive(:subscribe_to_event).and_return({})
  end

  def success_response(**body)
    {
      status: '200',
      body:
    }
  end

  def not_found_response
    { status: '400' }
  end
end
