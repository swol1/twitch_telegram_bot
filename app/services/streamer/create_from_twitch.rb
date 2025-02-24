# frozen_string_literal: true

class Streamer::CreateFromTwitch < BaseService
  class NotFoundError < StandardError; end

  def initialize(login)
    @login = login
    @twitch_api_client = TwitchApiClient.new
  end

  def call
    raise NotFoundError unless (streamer_data = fetch_streamer_data.presence)

    Streamer.create!(
      login: streamer_data[:login],
      twitch_id: streamer_data[:id],
      name: streamer_data[:display_name]
    ).tap do |streamer|
      Streamer::UpdateInfo.call(streamer)
      Streamer::SubscribeToTwitchEventsJob.perform_async(streamer.id)
      Streamer::ReconcileEnabledTwitchEventsJob.perform_in(10.minutes, streamer.id)
    end
  end

  private

  def fetch_streamer_data
    response = @twitch_api_client.get_streamer(@login)
    response[:status] == '200' ? response[:body][:data].first : nil
  end
end
