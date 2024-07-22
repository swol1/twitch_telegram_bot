# frozen_string_literal: true

class TwitchApiClient
  BASE_TWITCH_TOKEN_URL = 'https://id.twitch.tv/oauth2/token'
  BASE_TWITCH_API_URL = 'https://api.twitch.tv/helix'

  def initialize
    @client_id = App.secrets.twitch_client_id
    @client_secret = App.secrets.twitch_client_secret
    @message_secret = App.secrets.twitch_message_secret
    @callback_url = "#{App.secrets.public_api_url}/twitch/eventsub"
  end

  def subscribe_to_event(streamer_id, type, version)
    uri = URI("#{BASE_TWITCH_API_URL}/eventsub/subscriptions")
    body = {
      type:,
      version:,
      condition: { broadcaster_user_id: streamer_id },
      transport: {
        method: 'webhook',
        callback: @callback_url,
        secret: @message_secret
      }
    }
    post_request(uri, body)
  end

  def get_streamer(login)
    uri = URI("#{BASE_TWITCH_API_URL}/users?login=#{login}")
    get_request(uri)
  end

  def get_channel_info(twitch_id)
    uri = URI("#{BASE_TWITCH_API_URL}/channels?broadcaster_id=#{twitch_id}")
    get_request(uri)
  end

  private

  def access_token
    @_access_token ||= begin
      uri = URI(BASE_TWITCH_TOKEN_URL)
      response = Net::HTTP.post_form(
        uri,
        {
          client_id: @client_id,
          client_secret: @client_secret,
          grant_type: 'client_credentials'
        }
      )
      JSON.parse(response.body)['access_token']
    end
  end

  def get_request(uri)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Client-Id'] = @client_id

    execute_request(uri, request)
  end

  def post_request(uri, body)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Client-Id'] = @client_id
    request['Content-Type'] = 'application/json'
    request.body = body.to_json

    execute_request(uri, request)
  end

  def execute_request(uri, request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request(request)
      App.logger.log_error(nil, "Request failed: #{response.body}") unless %w[200 202].include?(response.code)
      { status: response.code, body: JSON.parse(response.body).deep_symbolize_keys }
    end
  end
end
