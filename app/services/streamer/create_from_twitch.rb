# frozen_string_literal: true

class Streamer::CreateFromTwitch < BaseService
  class NotFoundError < StandardError; end

  def initialize(login)
    @login = login
    @twitch_api_client = TwitchApiClient.new
  end

  def call
    raise NotFoundError unless (streamer_data = fetch_streamer_data.presence)

    # Twitch user can change its login and twitch_id will be the same but login is not
    # maybe it's better to unsubscribe users->destroy/create instead in this case, will see
    streamer = Streamer.find_or_initialize_by(twitch_id: streamer_data[:id])
    is_new = streamer.new_record?
    streamer.login = streamer_data[:login]
    streamer.name = streamer_data[:display_name]
    streamer.save!
    if is_new
      Streamer::UpdateInfo.call(streamer)
      Streamer::SubscribeToTwitchEventsJob.perform_async(streamer.id)
      Streamer::ReconcileEnabledTwitchEventsJob.perform_in(10.minutes, streamer.id)
    end
    streamer
  end

  private

  def fetch_streamer_data
    response = @twitch_api_client.get_streamer(@login)
    response[:status] == '200' ? response[:body][:data].first : nil
  end
end
