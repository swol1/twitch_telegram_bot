# frozen_string_literal: true

class Streamer::SubscribeToTwitchEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(streamer_id)
    streamer = Streamer.find(streamer_id)
    Streamer::SubscribeToTwitchEvents.call(streamer)
  end
end
