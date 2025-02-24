# frozen_string_literal: true

class TelegramBotClient
  def initialize
    @api = Telegram::Bot::Client.new(App.secrets.telegram_token).api
  end

  def send_message(message)
    RateLimiter.check('rate_limit:chats', limit: 29)
    RateLimiter.check("rate_limit:chat_#{message[:chat_id]}", limit: 1)

    message[:text] = sanitized_text(message[:text])
    @api.send_message(message)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    chat = Chat.find_by!(telegram_id: message[:chat_id])
    chat.destroy if e.data['error_code'] == 403
    App.logger.log_error(e, "Caught specific Telegram exception. Chat: #{chat.inspect}")
  rescue StandardError => e
    App.logger.log_error(e, "Delivery failure message: #{message[:text]} to chat #{message[:chat_id]}: #{e.message}")
  end

  private

  # only <b>, <i>, and <code> will not be escaped
  def sanitized_text(text)
    CGI.unescapeElement(CGI.escapeHTML(text.gsub('@', '')), 'B', 'I', 'CODE')
  end
end
