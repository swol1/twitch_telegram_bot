# frozen_string_literal: true

class TwitchEvent
  include ActiveModel::API

  kredis_flag :received, key: ->(f) { "event_id:#{f.id}:received" }

  attr_accessor :id, :type, :twitch_id, :name, :login, :category, :title

  validates :id, :type, :twitch_id, :name, :login, presence: true
  validates :type, inclusion: { in: ::EventSubscription::TYPES.keys }

  def not_duplicated?
    received.mark(expires_in: 600.seconds, force: false)
  end
end
