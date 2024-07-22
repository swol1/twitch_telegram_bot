# frozen_string_literal: true

module TelegramCommands
  class Subscribe < Base
    def execute
      text = subscribe_user_to_streamer
      send_message(text:)
    end

    private

    def login = @args

    def subscribe_user_to_streamer
      return I18n.t('errors.login_not_provided') unless login

      return I18n.t('errors.max_subs_reached') if user.max_subscriptions_reached?

      streamer = Streamer.find_or_create_from_twitch(login)
      handle_user_subscription(streamer)
    rescue Streamer::Twitch::Data::NotFoundError => _e
      I18n.t('errors.streamer_not_found', login:)
    rescue ActiveRecord::RecordInvalid => e
      App.logger.log_error(e, 'Invalid Streamer')
      I18n.t('errors.generic')
    end

    def handle_user_subscription(streamer)
      return I18n.t('errors.not_uniq_subscription', name: streamer.name) if user.subscribed_to?(streamer.id)

      if user.subscribe_to(streamer)
        streamer_info = streamer.info.to_text(:category, :title, :twitch, :telegram)
        I18n.t(
          'streamer_subscription.subscribed_success',
          name: streamer.name,
          left_subs: user.left_subscriptions
        ) + ("\n\n#{streamer_info}".presence || '')
      else
        I18n.t('errors.generic')
      end
    end
  end
end
