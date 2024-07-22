# frozen_string_literal: true

module Streamer::EventSubscriptions
  extend ActiveSupport::Concern

  included do
    has_many :event_subscriptions, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id', dependent: :destroy

    after_create :create_inactive_events
  end

  def inactive_events
    event_subscriptions.inactive
  end

  def activate_events_on_twitch
    Streamer::ActivatingEventsOnTwitchJob.perform_async(id)
    Streamer::CheckingEventsActivationJob.perform_in(10.minutes, id)
  end

  def create_inactive_events
    EventSubscription::TYPES.each do |type, version|
      event_subscriptions.create!(
        event_type: type,
        version:,
        streamer_twitch_id: twitch_id,
        status: :inactive
      )
    end
  end
end
