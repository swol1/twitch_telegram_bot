# frozen_string_literal: true

module TelegramCommands
  class Live < Base
    def call
      text = if live_streamers.blank?
               I18n.t('streamer_subscription.info.no_live')
             else
               I18n.t('streamer_subscription.info.live') + live_streamers_info_text
             end

      send_message(text:)
    end

    private

    def live_streamers
      @_live_streamers ||= chat.subscriptions.select do |streamer|
        streamer.channel_info[:status].to_s.casecmp?('online')
      end
    end

    def live_streamers_info_text
      live_streamers.map { Streamer::InfoPresenter.new(_1).to_text }.compact_blank.join("\n\n")
    end
  end
end
