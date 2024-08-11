# frozen_string_literal: true

class Streamer::Info
  using EmojiAppender

  def initialize(streamer)
    @streamer = streamer
  end

  def name_with_emoji = "<b>#{@streamer.name}</b>".append_emoji

  def to_text(*args)
    args = %i[name category title twitch telegram] if args.blank?
    formatted_attributes.values_at(*args).compact_blank.join("\n")
  end

  private

  def formatted_attributes
    channel_info = @streamer.channel_info.to_h
    return {} if channel_info.compact_blank.blank?

    category, title, status = channel_info.values_at(:category, :title, :status)
    {
      name: "<b>#{@streamer.name}</b>#{status_emoji(status)}",
      category: (I18n.t('streamer_subscription.info.category', category:) if category.present?),
      title: (I18n.t('streamer_subscription.info.title', title:) if title.present?),
      twitch: "twitch: https://twitch.tv/#{@streamer.login}",
      telegram: ("telegram: https://t.me/#{@streamer.telegram_login}" if @streamer.telegram_login.present?)
    }.compact_blank
  end

  def status_emoji(status)
    {
      'online' => ' 🟢',
      'offline' => ' 🔴'
    }[status&.downcase]
  end
end
