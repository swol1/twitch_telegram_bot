# frozen_string_literal: true

module TwitchEvents
  class ChannelUpdate < Base
    def call
      changed_fields = changed_channel_fields
      return if changed_fields.empty?

      update_streamer_info
      notify_subscribers(
        notification_data: {
          'category' => category,
          'title' => title,
          'changed_fields' => changed_fields,
          'stream_offline' => stream_offline?
        }
      )
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

    def changed_channel_fields
      fields = []
      fields << 'category' if value_changed?(channel_info[:category], category)
      fields << 'title' if value_changed?(channel_info[:title], title)
      fields
    end

    def stream_offline?
      channel_info[:status] == 'offline' &&
        @twitch_event.secs_since_prev_status_event >= App.secrets.stream_restart_threshold_seconds.to_i
    end

    def value_changed?(old_value, new_value)
      return true unless old_value && new_value

      !old_value.squish.casecmp?(new_value.squish)
    end
  end
end
