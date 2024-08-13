# frozen_string_literal: true

class TelegramBotClient
  def initialize
    @api = Telegram::Bot::Client.new(App.secrets.telegram_token).api
  end

  def send_message(message)
    RateLimiter.check('rate_limit:telegram_response', limit: 29)
    RateLimiter.check("rate_limit:chat_#{message[:chat_id]}", limit: 1)

    @api.send_message(message)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    user = User.find_by!(chat_id: message[:chat_id])
    user.destroy if e.data['error_code'] == 403
    App.logger.log_error(e, "Caught specific Telegram exception. User: #{user.inspect}")
  rescue StandardError => e
    App.logger.log_error(e, "Delivery failure message: #{message[:text]} to user #{message[:chat_id]}: #{e.message}")
  end
end
