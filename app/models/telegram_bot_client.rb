# frozen_string_literal: true

class TelegramBotClient
  def initialize
    @messages_rate_limiter = TelegramMessagesRateLimiter.new
    @api = Telegram::Bot::Client.new(App.secrets.telegram_token).api
  end

  def send_message(message)
    @messages_rate_limiter.wait_if_limits_exceeded(message[:chat_id])
    @api.send_message(message)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    user = User.find_by!(chat_id: message[:chat_id])
    user.destroy if e.data['error_code'] == 403
    App.logger.log_error(e, "Caught specific Telegram exception. User: #{user.inspect}")
  rescue StandardError => e
    App.logger.log_error(e, "Delivery failure message: #{message[:text]} to user #{message[:chat_id]}: #{e.message}")
  end
end
