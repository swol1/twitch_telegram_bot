# frozen_string_literal: true

module TwitchEvents
  class Base < BaseService
    def initialize(twitch_event)
      @twitch_event = twitch_event
    end

    def call
      raise NotImplementedError, "#{self.class} must implement the 'call' method"
    end

    private

    def streamer = @twitch_event.streamer
    def subscribers = streamer.subscribers
    def channel_info = @_channel_info ||= streamer.channel_info

    def notify_subscribers(notification_data: {})
      subscribers.find_each.with_index do |subscriber, index|
        TwitchEvents::DeliverNotificationJob.perform_in(
          index / 29,
          subscriber.id,
          streamer.id,
          @twitch_event.type,
          notification_data
        )
      end
    end
  end
end
