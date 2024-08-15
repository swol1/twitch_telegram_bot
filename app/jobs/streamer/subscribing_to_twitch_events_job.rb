# frozen_string_literal: true

class EventSubscriptionNotCreatedError < StandardError; end

class Streamer::SubscribingToTwitchEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(streamer_id)
    streamer = Streamer.find(streamer_id)
    enabled_event_types = streamer.enabled_events.pluck(:event_type)
    not_enabled_event_types = EventSubscription::TYPES.except(*enabled_event_types)
    return if not_enabled_event_types.blank?

    not_enabled_event_types.each do |type, version|
      response = twitch_api_client.subscribe_to_event(streamer.twitch_id, type, version)

      if already_subscribed?(response)
        mark_as_enabled(streamer.twitch_id, type)
      elsif (event_data = response_event_data(response))
        create_event_subscription!(type, version, streamer.twitch_id, event_data[:id])
      else
        handle_subscription_error(response, streamer, type)
      end
    end
  end

  private

  def twitch_api_client = @_twitch_api_client ||= TwitchApiClient.new

  def mark_as_enabled(streamer_twitch_id, event_type)
    EventSubscription.find_by!(streamer_twitch_id:, event_type:).enabled!
  end

  def create_event_subscription!(event_type, version, streamer_twitch_id, twitch_id)
    EventSubscription.create!(event_type:, version:, streamer_twitch_id:, twitch_id:)
  end

  def response_event_data(response)
    %w[202 200].include?(response[:status]) ? response[:body][:data].first : nil
  end

  def already_subscribed?(response)
    response.dig(:body, :message)&.downcase == 'subscription already exists'
  end

  def handle_subscription_error(response, streamer, event_type)
    raise EventSubscriptionNotCreatedError, <<~ERROR_MSG
      Failed to create subscription.
      Response: #{response.inspect}
      Streamer: #{streamer.inspect}
      Event: #{event_type}
    ERROR_MSG
  end
end
