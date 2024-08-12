# frozen_string_literal: true

class Streamer::UnsubscribingFromTwitchEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(streamer_id)
    streamer = Streamer.find(streamer_id)
    streamer.event_subscriptions.each do |event|
      next if event.revoked?

      response = TwitchApiClient.new.delete_subscription_to_event(event.twitch_id)
      next if %w[204 404].include?(response[:status])

      App.logger.log_error(
        nil,
        "Subscription was not deleted: #{event.inspect}. Response: #{response.inspect}"
      )
    end
  end
end
