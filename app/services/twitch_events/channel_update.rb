# frozen_string_literal: true

module TwitchEvents
  class ChannelUpdate < Base
    def call
      return if values_unchanged?

      update_streamer_info
      notify_subscribers(text: text_with_locales)
    end

    private

    def category = @twitch_event.payload['category_name']
    def title = @twitch_event.payload['title']

    def update_streamer_info
      channel_info.update(category:, title:)
      streamer.set_telegram_login_from_title
    end

    def subscribers
      category == 'Just Chatting' ? super : super.without_just_chatting_mode
    end

    def values_unchanged?
      cached_category, cached_title = channel_info.values_at(:category, :title)
      return false unless cached_category && cached_title

      cached_category.squish.casecmp?(category.squish) && cached_title.squish.casecmp?(title.squish)
    end

    def text_with_locales
      I18n.with_all_locales do
        text = I18n.t('streamer_notification.update', streamer_name:, category:, title:)
        text += I18n.t('streamer_notification.offline') if channel_info.to_h.fetch(:status, 'offline') == 'offline'
        text
      end
    end
  end
end
