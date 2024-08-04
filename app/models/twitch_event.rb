# frozen_string_literal: true

class TwitchEvent
  include ActiveModel::API

  kredis_flag :received, key: ->(f) { "event_id:#{f.id}:received" }

  attr_accessor :id, :type, :twitch_id, :name, :login, :category, :title, :created_at

  validates :id, :type, :twitch_id, :name, :login, :created_at, presence: true
  validates :type, inclusion: { in: ::EventSubscription::TYPES.keys }

  def not_duplicated?
    received.mark(expires_in: 600.seconds, force: false)
  end

  def correct_order?
    seconds_since_last_event.positive?
  end

  def seconds_since_last_event
    @_seconds_since_last_event ||= calculate_seconds_since_last_event
  end

  def streamer
    @_streamer ||= Streamer.find_by!(twitch_id:)
  end

  private

  def calculate_seconds_since_last_event
    last_event_time = streamer.channel_info[:created_at].presence || 1.day.ago
    Time.parse(created_at) - Time.parse(last_event_time.to_s)
  end
end
