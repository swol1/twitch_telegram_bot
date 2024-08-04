# frozen_string_literal: true

module TwitchEvents
  class StreamOffline < Base
    def process
      update_channel_info
    end

    private

    def update_channel_info
      channel_info[:status] = 'offline'
      channel_info[:created_at] = @event.created_at
    end
  end
end
