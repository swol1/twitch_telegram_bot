# frozen_string_literal: true

class MiddlewareRequestLogger < GrapeLogging::Middleware::RequestLogger
  def initialize(app, options = {})
    default_options = {
      logger: App.logger,
      log_level: App.env.production? ? 'info' : 'debug',
      formatter: App.env.production? ? GrapeLogging::Formatters::Json.new : GrapeLogging::Formatters::Default.new,
      include: [
        GrapeLogging::Loggers::Response.new,
        GrapeLogging::Loggers::RequestHeaders.new
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
