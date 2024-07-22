# frozen_string_literal: true

module User::Subscriber
  extend ActiveSupport::Concern

  MAX_SUBSCRIPTIONS = 15

  included do
    has_many :user_streamer_subscriptions, dependent: :destroy
    has_many :subscriptions, through: :user_streamer_subscriptions, source: :streamer
  end

  def subscribed_to?(streamer_id) = subscriptions.exists?(streamer_id)
  def max_subscriptions_reached? = subscriptions.count >= MAX_SUBSCRIPTIONS
  def left_subscriptions = MAX_SUBSCRIPTIONS - subscriptions.count

  def subscribe_to(streamer)
    subscriptions << streamer unless max_subscriptions_reached?
  end

  def unsubscribe_from(login)
    streamer = Streamer.find_by(login:)
    subscription = subscriptions.find_by(id: streamer&.id)
    return unless streamer && subscription

    subscription.destroy
  end

  def unsubscribe_from_all
    subscriptions.destroy_all
  end
end
