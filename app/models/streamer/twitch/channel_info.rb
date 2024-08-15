# frozen_string_literal: true

class Streamer
  module Twitch
    class ChannelInfo
      def initialize(streamer)
        @streamer = streamer
        @twitch_api_client = TwitchApiClient.new
      end

      def update_streamer_channel_info
        return if @streamer.channel_info[:title].present?
        return unless (channel_info = fetch_channel_info.presence)

        @streamer.channel_info.update(
          category: channel_info[:game_name],
          title: channel_info[:title]
        )
        @streamer.set_telegram_login_from_title
      end

      private

      def fetch_channel_info
        response = @twitch_api_client.get_channel_info(@streamer.twitch_id)
        response[:status] == '200' ? response[:body][:data].first : nil
      end
    end
  end
end
