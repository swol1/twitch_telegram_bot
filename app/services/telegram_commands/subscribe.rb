# frozen_string_literal: true

module TelegramCommands
  class Subscribe < Base
    def call
      text = subscribe_chat_to_streamer
      send_message(text:)
    end

    private

    def login = @args

    def subscribe_chat_to_streamer
      return I18n.t('errors.login_not_provided') unless login
      return I18n.t('errors.max_subs_reached') if chat.max_subscriptions_reached?

      streamer = find_or_create_streamer(login)
      return I18n.t('errors.not_uniq_subscription', name: streamer.name) if chat.subscribed_to?(streamer.id)

      chat.subscriptions << streamer
      streamer_info_text(streamer)
    rescue Streamer::CreateFromTwitch::NotFoundError => _e
      I18n.t('errors.streamer_not_found', login:)
    rescue ActiveRecord::RecordInvalid => e
      App.logger.log_error(e, 'Invalid Streamer')
      I18n.t('errors.generic')
    end

    def find_or_create_streamer(login)
      Streamer.find_by(login:) || Streamer::CreateFromTwitch.call(login)
    end

    def streamer_info_text(streamer)
      streamer_info = Streamer::InfoPresenter.new(streamer).to_text(:category, :title, :twitch, :telegram)
      I18n.t(
        'streamer_subscription.subscribed_success',
        name: streamer.name,
        left_subs: chat.left_subscriptions
      ) + ("\n\n#{streamer_info}".presence || '')
    end
  end
end
