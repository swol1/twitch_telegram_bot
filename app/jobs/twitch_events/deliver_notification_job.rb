# frozen_string_literal: true

module TwitchEvents
  class DeliverNotificationJob
    include Sidekiq::Job

    sidekiq_options retry: 0

    def perform(subscriber_id, streamer_id, event_type, notification_data = {})
      subscriber = Chat.find(subscriber_id)
      streamer = Streamer.find(streamer_id)

      TelegramBotClient.new.send_message(
        chat_id: subscriber.telegram_id,
        text: I18n.with_locale(subscriber.locale) { notification_text(event_type, streamer, notification_data) },
        reply_markup: Streamer::TelegramKeyboardPresenter.new(streamer).social_links_keyboard,
        disable_web_page_preview: true,
        parse_mode: :html
      )
    end

    private

    def notification_text(event_type, streamer, notification_data)
      case event_type
      when 'stream.online'
        I18n.t('streamer_notification.online', streamer_name: streamer_name(streamer))
      when 'channel.update'
        channel_update_text(streamer, notification_data)
      when 'user.update'
        user_update_text(notification_data)
      end
    end

    def channel_update_text(streamer, notification_data)
      category = notification_data['category']
      title = notification_data['title']
      changed_fields = notification_data.fetch('changed_fields')

      lines = [
        streamer_name(streamer),
        update_line(I18n.t('streamer_notification.category'), category, changed_fields.include?('category')),
        update_line(I18n.t('streamer_notification.title'), title, changed_fields.include?('title'))
      ]
      lines += ['', I18n.t('streamer_notification.offline')] if notification_data['stream_offline']
      lines.join("\n")
    end

    def streamer_name(streamer)
      Streamer::InfoPresenter.new(streamer).name_with_emoji
    end

    def update_line(label, value, changed)
      "#{label}: #{changed ? "<b>#{value}</b>" : value}"
    end

    def user_update_text(notification_data)
      I18n.t(
        'streamer_notification.info_update',
        old_name: notification_data['old_name'],
        login: notification_data['login'],
        name: notification_data['name']
      )
    end
  end
end
