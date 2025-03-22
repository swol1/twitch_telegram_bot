# frozen_string_literal: true

class IgnoreBadRequestsMiddleware < Grape::Middleware::Base
  IGNORED_PATHS = ['/', '/index.htm'].freeze

  def call(env)
    if IGNORED_PATHS.include?(env['PATH_INFO'])
      [404, { 'Content-Type' => 'text/plain' }, ['bb']]
    else

      @app.call(env)
    end
  end
end
