# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchApiClient do
  let(:client) { described_class.new }
  let(:base_url) { TwitchApiClient::BASE_TWITCH_API_URL }
  let(:token_url) { TwitchApiClient::BASE_TWITCH_TOKEN_URL }
  let(:access_token) { 'mocked_access_token' }

  before do
    stub_request(:post, token_url)
      .to_return(body: { access_token: }.to_json, status: 200)
    allow(RateLimiter).to receive(:check).with('rate_limit:twitch_requests', limit: 29).and_return(nil)
  end

  describe '#subscribe_to_event' do
    it 'makes the correct POST request to subscribe to an event' do
      stub_request(:post, "#{base_url}/eventsub/subscriptions")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Client-Id' => App.secrets.twitch_client_id,
            'Content-Type' => 'application/json'
          },
          body: {
            type: 'stream.online',
            version: '1',
            condition: { broadcaster_user_id: '12345' },
            transport: {
              method: 'webhook',
              callback: "#{App.secrets.public_api_url}/twitch/eventsub",
              secret: App.secrets.twitch_message_secret
            }
          }.to_json
        )
        .to_return(status: 202, body: {}.to_json)

      client.subscribe_to_event('12345', 'stream.online', '1')

      expect(WebMock).to have_requested(:post, "#{base_url}/eventsub/subscriptions").once
    end
  end

  describe '#get_streamer' do
    it 'makes the correct GET request to retrieve a streamer' do
      stub_request(:get, "#{base_url}/users?login=testuser")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Client-Id' => App.secrets.twitch_client_id
          }
        )
        .to_return(status: 200, body: { data: [{ id: '12345', login: 'testuser' }] }.to_json)

      response = client.get_streamer('testuser')

      expect(WebMock).to have_requested(:get, "#{base_url}/users?login=testuser").once
      expect(response[:body][:data].first[:login]).to eq('testuser')
    end
  end

  describe '#get_channel_info' do
    it 'makes the correct GET request to retrieve channel information' do
      stub_request(:get, "#{base_url}/channels?broadcaster_id=12345")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Client-Id' => App.secrets.twitch_client_id
          }
        )
        .to_return(status: 200, body: { data: [{ id: '12345', broadcaster_name: 'testuser' }] }.to_json)

      response = client.get_channel_info('12345')

      expect(WebMock).to have_requested(:get, "#{base_url}/channels?broadcaster_id=12345").once
      expect(response[:body][:data].first[:broadcaster_name]).to eq('testuser')
    end
  end

  describe '#get_all_app_subscriptions' do
    it 'makes the correct GET request to retrieve all app subscriptions' do
      stub_request(:get, "#{base_url}/eventsub/subscriptions")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Client-Id' => App.secrets.twitch_client_id
          }
        )
        .to_return(status: 200, body: { data: [] }.to_json)

      response = client.get_all_app_subscriptions

      expect(WebMock).to have_requested(:get, "#{base_url}/eventsub/subscriptions").once
      expect(response[:body][:data]).to eq([])
    end
  end

  describe '#delete_subscription_to_event' do
    it 'makes the correct DELETE request to remove an event subscription' do
      stub_request(:delete, "#{base_url}/eventsub/subscriptions?id=subscription_id")
        .with(
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Client-Id' => App.secrets.twitch_client_id
          }
        )
        .to_return(status: 204)

      response = client.delete_subscription_to_event('subscription_id')

      expect(WebMock).to have_requested(:delete, "#{base_url}/eventsub/subscriptions?id=subscription_id").once
      expect(response[:status]).to eq('204')
    end
  end

  describe '#execute_request' do
    it 'logs an error if the request fails' do
      uri = URI("#{base_url}/users?login=invaliduser")
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Client-Id'] = App.secrets.twitch_client_id

      stub_request(:get, uri.to_s)
        .to_return(status: 404, body: { message: 'Not Found' }.to_json)

      expect(App.logger).to receive(:log_error)
        .with(nil, 'Request failed: {"message":"Not Found"}')

      client.send(:execute_request, uri, request)

      expect(RateLimiter).to have_received(:check).with('rate_limit:twitch_requests', limit: 29)
    end
  end
end
