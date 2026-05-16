# frozen_string_literal: true

class HandleTwitchEventJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  EVENT_HANDLERS = {
    'channel.update' => TwitchEvents::ChannelUpdate,
    'stream.online' => TwitchEvents::StreamOnline,
    'stream.offline' => TwitchEvents::StreamOffline,
    'user.update' => TwitchEvents::UserUpdate
  }.freeze

  def perform(event_params)
    twitch_event = TwitchEvent.new(event_params)
    if twitch_event.valid? && twitch_event.not_duplicated?
      EVENT_HANDLERS.fetch(twitch_event.type).call(twitch_event)
    else
      App.logger.log_error(
        nil,
        "Event was not processed: #{twitch_event.inspect}. " \
        "valid: #{twitch_event.valid?}, not_duplicated: #{twitch_event.not_duplicated?}"
      )
    end
  end
end
