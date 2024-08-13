# frozen_string_literal: true

class PendingEventsError < StandardError; end

class Streamer::CheckingEnabledEventsJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  sidekiq_retry_in { 10.minutes.to_i }

  def perform(streamer_id)
    return unless (streamer = Streamer.find_by(id: streamer_id))
    return if streamer.pending_events.blank?

    Streamer::SubscribingToTwitchEventsJob.perform_async(streamer.id)

    raise PendingEventsError, "Streamer: #{streamer_id}. Pending Events: #{streamer.pending_events.inspect}"
  end
end
