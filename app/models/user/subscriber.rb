# frozen_string_literal: true

module User::Subscriber
  extend ActiveSupport::Concern

  included do
    has_many :user_streamer_subscriptions, dependent: :destroy
    has_many :subscriptions, through: :user_streamer_subscriptions, source: :streamer
  end

  def subscribed_to?(streamer_id) = subscriptions.exists?(streamer_id)
  def max_subscriptions_reached? = subscriptions.count >= App.secrets.max_user_subscriptions
  def left_subscriptions = App.secrets.max_user_subscriptions - subscriptions.count

  def subscribe_to(streamer)
    subscriptions << streamer unless max_subscriptions_reached?
  end

  def unsubscribe_from(login)
    streamer = Streamer.find_by(login:)
    subscription = subscriptions.find_by(id: streamer&.id)
    return false unless streamer && subscription

    subscription.destroy!
  end

  def unsubscribe_from_all
    subscriptions.destroy_all
  end
end
