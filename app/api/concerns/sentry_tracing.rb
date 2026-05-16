# frozen_string_literal: true

module SentryTracing
  TARGET_PATHS = ['/telegram/webhook', '/twitch/eventsub'].freeze

  def self.included(base)
    base.before do
      if TARGET_PATHS.include?(request.path)
        transaction_name = SentryTracing.build_transaction_name(request, params)
        transaction = Sentry.start_transaction(op: 'http.server', name: transaction_name)
        env['sentry.transaction'] = transaction
      end
    end

    base.after { env['sentry.transaction']&.finish }
  end

  def self.build_transaction_name(request, params)
    name = "#{request.request_method} #{request.path}"
    return name unless request.path == '/telegram/webhook'

    command = params.dig(:message, :text).to_s.downcase.split.first
    return name unless command&.start_with?('/')

    "#{name} #{command}"
  end
end
