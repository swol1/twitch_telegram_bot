# frozen_string_literal: true

class IgnoreBadRequestsMiddleware
  IGNORED_PATHS = ['/', '/index.htm'].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    if IGNORED_PATHS.include?(env['PATH_INFO'])
      [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
    else
      @app.call(env)
    end
  end
end
