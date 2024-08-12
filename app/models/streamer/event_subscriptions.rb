# frozen_string_literal: true

module Streamer::EventSubscriptions
  extend ActiveSupport::Concern

  included do
    has_many :event_subscriptions, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id', dependent: :destroy

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
    Streamer::UnsubscribingFromTwitchEventsJob.perform_async(id)
  end
end
