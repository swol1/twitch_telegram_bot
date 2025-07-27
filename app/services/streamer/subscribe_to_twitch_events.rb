# frozen_string_literal: true

class EventSubscriptionNotCreatedError < StandardError; end

class Streamer::SubscribeToTwitchEvents < BaseService
  def initialize(streamer)
    @streamer = streamer
    @twitch_api_client = TwitchApiClient.new
  end

  def call
    missing = EventSubscription::TYPES - @streamer.enabled_events.pluck(:event_type)
    missing.each do |type|
      config = EventSubscription.config_for(type)
      condition = { config[:condition_key] => @streamer.twitch_id }
      response = @twitch_api_client.subscribe_to_event(condition, type, config[:version])

      if already_subscribed?(response)
        enable_event_subscription!(@streamer.twitch_id, type)
      elsif (event_data = response_event_data(response))
        create_event_subscription!(type, config[:version], @streamer.twitch_id, event_data[:id])
      else
        handle_error(response, type)
      end
    end
  end

  private

  def enable_event_subscription!(streamer_twitch_id, event_type)
    EventSubscription.find_by!(streamer_twitch_id:, event_type:).enabled!
  end

  def create_event_subscription!(event_type, version, streamer_twitch_id, twitch_id)
    EventSubscription.create_event_subscription!(event_type:, version:, streamer_twitch_id:, twitch_id:)
  end

  def response_event_data(response)
    %w[202 200].include?(response[:status]) ? response[:body][:data].first : nil
  end

  def already_subscribed?(response)
    response.dig(:body, :message)&.downcase == 'subscription already exists'
  end

  def handle_error(response, event_type)
    raise EventSubscriptionNotCreatedError, <<~ERROR_MSG
      Failed to create event subscription.
      Response: #{response.inspect}
      Streamer: #{@streamer.inspect}
      Event: #{event_type}
    ERROR_MSG
  end
end
