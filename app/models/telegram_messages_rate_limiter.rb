# frozen_string_literal: true

# Telegram has a limit of 30 messages per second for a bot
# and 1 message per second per user
class TelegramMessagesRateLimiter
  def initialize(limit = 29)
    @total_messages_limiter = Kredis.limiter('rate_limit:total_messages', limit:, expires_in: 1.second)
  end

  def wait_if_limits_exceeded(chat_id)
    setup_chat_limiter(chat_id)
    sleep 0.1 while limits_exceeded?
    poke_limits
  end

  private

  def setup_chat_limiter(chat_id)
    @chat_messages_limiter = Kredis.limiter("rate_limit:chat_#{chat_id}", limit: 1, expires_in: 1.second)
  end

  def limits_exceeded? = @total_messages_limiter.exceeded? || @chat_messages_limiter.exceeded?

  def poke_limits
    @total_messages_limiter.poke
    @chat_messages_limiter.poke
  end
end
