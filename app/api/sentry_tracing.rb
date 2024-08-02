# frozen_string_literal: true

module SentryTracing
  def self.included(base)
    base.before do
      url = request.path
      method = request.request_method
      message_text = url == '/telegram/webhook' ? params.dig(:message, :text).downcase.split[0] : ''

      transaction = Sentry.start_transaction(
        op: 'http.server',
        name: "#{method} #{url} #{message_text}"
      )

      env['sentry.transaction'] = transaction
    end

    base.after { env['sentry.transaction']&.finish }
  end
end
