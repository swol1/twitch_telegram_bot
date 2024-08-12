# frozen_string_literal: true

class EventSubscription < ActiveRecord::Base
  # Available notification types with versions
  TYPES = {
    'channel.update' => '2',
    'stream.online' => '1',
    'stream.offline' => '1'
  }.freeze

  belongs_to :streamer, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id'

  enum :status, %i[pending enabled revoked], default: :pending

  validates :event_type, presence: true, inclusion: { in: TYPES.keys }
  validates :event_type, uniqueness: { scope: :streamer_twitch_id, message: 'should be unique per streamer' }
  validates :streamer_twitch_id, :twitch_id, presence: true
end
