# frozen_string_literal: true

class MiddlewareRequestLogger < GrapeLogging::Middleware::RequestLogger
  def initialize(app, options = {})
    options = options.presence || {
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
    super
  end

  # silence logs for healthcheck
  def call(env)
    if env['PATH_INFO'] == '/up'
      @app.call(env)
    else
      super
    end
  end
end
