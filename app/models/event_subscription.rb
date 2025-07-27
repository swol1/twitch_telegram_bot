# frozen_string_literal: true

class EventSubscription < ActiveRecord::Base
  # Available notification types with config
  CONFIG = {
    'channel.update' => { version: '2', condition_key: 'broadcaster_user_id' },
    'stream.online' => { version: '1', condition_key: 'broadcaster_user_id' },
    'stream.offline' => { version: '1', condition_key: 'broadcaster_user_id' },
    'user.update' => { version: '1', condition_key: 'user_id' }
  }.freeze
  TYPES = CONFIG.keys.freeze

  belongs_to :streamer, primary_key: 'twitch_id', foreign_key: 'streamer_twitch_id'

  enum :status, %i[pending enabled revoked], default: :pending

  validates :event_type, presence: true, inclusion: { in: TYPES }
  validates :event_type, uniqueness: { scope: :streamer_twitch_id, message: 'should be unique per streamer' }
  validates :streamer_twitch_id, :twitch_id, presence: true

  def self.config_for(event_type)
    CONFIG.fetch(event_type)
  end
end
