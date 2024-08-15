# frozen_string_literal: true

class Root < Grape::API
  insert_before Grape::Middleware::Error, MiddlewareRequestLogger
  include SentryTracing

  helpers do
    def logger = App.logger
  end

  mount ::TwitchWebhook => '/twitch'
  mount ::TelegramWebhook => '/telegram'

  get '/up' do
    return_no_content
  end

  route :any, '*path' do
    error!({ message: 'resource does not exist' }, 404)
  end
end
