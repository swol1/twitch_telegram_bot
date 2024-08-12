# frozen_string_literal: true

class TwitchEvent
  include ActiveModel::API

  kredis_flag :received, key: ->(f) { "event_id:#{f.id}:received" }

  attr_accessor :id, :type, :twitch_id, :category, :title, :received_at

  validates :id, :type, :twitch_id, :received_at, presence: true
  validate :correct_status_event_order, if: -> { ['stream.online', 'stream.offline'].include?(type) }

  def not_duplicated?
    received.mark(expires_in: 600.seconds, force: false)
  end

  def correct_status_event_order
    errors.add(:base, 'Incorrect status order') if secs_since_prev_status_event.negative?
  end

  def secs_since_prev_status_event
    Time.parse(received_at) - Time.parse(prev_status_event_time)
  end

  def streamer
    @_streamer ||= EventSubscription.find_by!(twitch_id:).streamer
  end

  private

  def prev_status_event_time
    @_prev_status_event_time ||= streamer.channel_info[:status_received_at].presence || 1.day.ago.iso8601
  end
end
