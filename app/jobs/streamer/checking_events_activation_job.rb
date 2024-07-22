# frozen_string_literal: true

class EventsInactiveError < StandardError; end

class Streamer::CheckingEventsActivationJob
  include Sidekiq::Job
  sidekiq_options retry: 3

  sidekiq_retry_in { 10.minutes.to_i }

  sidekiq_retries_exhausted do |job, _ex|
    Sidekiq.logger.warn "Failed #{job['class']} with #{job['args']}: #{job['error_message']}"
  end

  def perform(streamer_id)
    inactive_events = Streamer.find(streamer_id).inactive_events
    return if inactive_events.blank?

    Streamer::ActivatingEventsOnTwitchJob.perform_async(streamer_id)
    return unless inactive_events.reload.present?

    raise EventsInactiveError,
          "Streamer: #{streamer_id} Events: #{inactive_events.pluck(:id)}"
  end
end
