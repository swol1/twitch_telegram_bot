# frozen_string_literal: true

class UserStreamerSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :streamer

  validates :user_id, uniqueness: { scope: :streamer_id }
end
