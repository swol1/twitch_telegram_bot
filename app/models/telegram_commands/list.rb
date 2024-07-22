# frozen_string_literal: true

module TelegramCommands
  class List < Base
    def execute
      text = if streamers.blank?
               I18n.t('streamer_subscription.info.not_subscribed')
             else
               subscriptions_text + streamers_info_text
             end
      send_message(text:)
    end

    private

    def streamers = @_streamers ||= user.subscriptions

    def subscriptions_text
      subscribed_to = streamers.map { "<b>#{_1.login}</b>" }.join(', ')
      I18n.t('streamer_subscription.info.subscribed_to', streamers: subscribed_to)
    end

    def streamers_info_text
      info = streamers.map { _1.info.to_text }.compact_blank.join("\n\n")
      info.presence || I18n.t('streamer_subscription.info.not_available')
    end
  end
end
