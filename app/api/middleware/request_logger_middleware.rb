# frozen_string_literal: true

class RequestLoggerMiddleware < GrapeLogging::Middleware::RequestLogger
  class FilteredRequestHeaders < GrapeLogging::Loggers::RequestHeaders
    SENSITIVE_HEADER_NAMES = %w[
      Twitch-Eventsub-Message-Signature
      X-Telegram-Bot-Api-Secret-Token
    ].freeze

    def parameters(request, response)
      super.tap do |params|
        params[:headers].each_key do |header_name|
          params[:headers][header_name] = '[FILTERED]' if SENSITIVE_HEADER_NAMES.include?(header_name)
        end
      end
    end
  end

  def initialize(app, options = {})
    default_options = {
      logger: App.logger,
      log_level: App.env.production? ? 'info' : 'debug',
      formatter: App.env.production? ? GrapeLogging::Formatters::Json.new : GrapeLogging::Formatters::Default.new,
      include: [
        GrapeLogging::Loggers::Response.new,
        FilteredRequestHeaders.new
      ]
    }
    super(app, default_options.merge(options))
  end

  # silence logging for healthcheck
  def call(env)
    return @app.call(env) if env['PATH_INFO'] == '/up'

    super
  end
end
