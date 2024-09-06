# frozen_string_literal: true

class ChatStreamerSubscription < ActiveRecord::Base
  belongs_to :chat
  belongs_to :streamer

  validates :chat_id, uniqueness: { scope: :streamer_id }

  after_destroy -> { streamer.destroy if streamer.subscribers.blank? }
end