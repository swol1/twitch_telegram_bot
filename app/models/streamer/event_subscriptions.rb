# frozen_string_literal: true

module Streamer::EventSubscriptions
  extend ActiveSupport::Concern

  included do
    has_many :event_subscriptions, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id'

    before_destroy :unsubscribe_from_twitch_events
  end

  def pending_events
    event_subscriptions.pending
  end

  def enabled_events
    event_subscriptions.enabled
  end

  def subscribe_to_twitch_events
    Streamer::SubscribingToTwitchEventsJob.perform_async(id)
    Streamer::CheckingEnabledEventsJob.perform_in(10.minutes, id)
  end

  def unsubscribe_from_twitch_events
    twitch_ids = event_subscriptions.pluck(:twitch_id)
    throw(:abort) if twitch_ids.size != 3 || event_subscriptions.any?(&:pending?)

    Streamer::UnsubscribingFromTwitchEventsJob.perform_async(twitch_ids) unless event_subscriptions.all?(&:revoked?)
    event_subscriptions.destroy_all
  end
end
