# frozen_string_literal: true

class Streamer
  module Twitch
    class Data
      class NotFoundError < StandardError; end

      def initialize(login)
        @login = login
        @twitch_api_client = TwitchApiClient.new
      end

      def create_streamer!
        raise NotFoundError unless (streamer_data = fetch_streamer_data.presence)

        Streamer.create!(
          login: streamer_data[:login],
          twitch_id: streamer_data[:id],
          name: streamer_data[:display_name]
        )
      end

      private

      def fetch_streamer_data
        response = @twitch_api_client.get_streamer(@login)
        response[:status] == '200' ? response[:body][:data].first : nil
      end
    end
  end
end
