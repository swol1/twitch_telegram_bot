# frozen_string_literal: true

class Root < Grape::API
  insert_before Grape::Middleware::Error, MiddlewareRequestLogger
  include SentryTracing

  # send tracing to sentry
  before do
    Sentry.set_tags(endpoint: env['api.endpoint'].options[:path].join('/'))
    transaction = Sentry.start_transaction(
      op: 'http.server',
      name: "#{request.request_method} #{env['api.endpoint'].options[:path].join('/')}"
    )
    env['sentry.transaction'] = transaction
  end

  after do
    env['sentry.transaction']&.finish
  end

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
