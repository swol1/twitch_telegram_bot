# frozen_string_literal: true

class Streamer::ActivatingEventsOnTwitchJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(streamer_id)
    streamer = Streamer.find(streamer_id)
    streamer.event_subscriptions.inactive.each do |event|
      response = twitch_api_client.subscribe_to_event(
        event.streamer_twitch_id,
        event.event_type,
        event.version
      )
      event.active! if already_subscribed?(response)
    end
  end

  private

  def twitch_api_client = @_twitch_api_client ||= TwitchApiClient.new

  def already_subscribed?(response)
    response[:body][:message]&.downcase == 'subscription already exists'
  end
end
