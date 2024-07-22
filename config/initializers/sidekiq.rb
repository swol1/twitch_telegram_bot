# frozen_string_literal: true

redis = { url: App.secrets.redis_url }
Sidekiq.configure_client do |config|
  config.redis = redis
end

Sidekiq.configure_server do |config|
  config.redis = redis
end
