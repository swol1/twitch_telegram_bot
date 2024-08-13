# frozen_string_literal: true

class RateLimiter
  def self.check(key, limit:, expires_in: 1.second)
    limiter = Kredis.limiter(key, limit:, expires_in:)
    sleep 0.1 while limiter.exceeded?
    limiter.poke
  end
end
