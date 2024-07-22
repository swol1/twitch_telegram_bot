# frozen_string_literal: true

class Root < Grape::API
  insert_before Grape::Middleware::Error, GrapeLogging::Middleware::RequestLogger,
                {
                  logger: App.logger,
                  log_level: App.env.production? ? 'info' : 'debug',
                  formatter: if App.env.production?
                               GrapeLogging::Formatters::Json.new
                             else
                               GrapeLogging::Formatters::Default.new
                             end,
                  include: [
                    GrapeLogging::Loggers::Response.new,
                    GrapeLogging::Loggers::RequestHeaders.new
                  ]
                }

  helpers do
    def logger = App.logger
  end

  mount ::TwitchWebhook => '/twitch'
  mount ::TelegramWebhook => '/telegram'

  get '/up' do
    { message: 'Application is up and running' }
  end

  route :any, '*path' do
    error!({ message: 'resource does not exist' }, 404)
  end
end
