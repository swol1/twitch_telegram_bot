# frozen_string_literal: true

Rack::Attack.cache.store = Kredis.redis
Rack::Attack.throttle('req/telegram_user', limit: 20, period: 60.seconds) do |req|
  if req.path.start_with?('/telegram/webhook')
    req_body = req.body.read
    req.body.rewind
    user_id = JSON.parse(req_body).dig('message', 'from', 'id')
    user_id
  end
end

# if set 429 or 503 telegram will keep sending
Rack::Attack.throttled_responder = lambda do |_env|
  [200, {}, ["OK\n"]]
end
