# frozen_string_literal: true

module TwitchEvents
  class StreamOffline < Base
    def process
      channel_info[:status] = 'offline'
    end
  end
end
