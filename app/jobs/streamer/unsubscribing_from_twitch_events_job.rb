# frozen_string_literal: true

class Streamer::UnsubscribingFromTwitchEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(twitch_ids)
    twitch_ids.each do |twitch_id|
      response = TwitchApiClient.new.delete_subscription_to_event(twitch_id)
      next if %w[204 404].include?(response[:status])

      App.logger.log_error(
        nil,
        "Subscription was not deleted: #{twitch_id}. Response: #{response.inspect}"
      )
    end
  end
end
