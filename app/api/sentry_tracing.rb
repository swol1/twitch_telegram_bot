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
    "#{request.request_method} #{request.path}".tap do |name|
      if request.path == '/telegram/webhook' && (message_text = params.dig(:message, :text))
        name + " #{message_text.downcase.split.first}"
      end
    end
  end
end
