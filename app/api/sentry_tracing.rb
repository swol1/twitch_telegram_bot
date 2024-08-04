# frozen_string_literal: true

module SentryTracing
  def self.included(base)
    base.before do
      url = request.path
      if ['/telegram/webhook', '/twitch/eventsub'].include?(url)
        name = "#{request.request_method} #{url}"
        if url == '/telegram/webhook' && (message_text = params.dig(:message, :text))
          name += " #{message_text.downcase.split.first}"
        end
        transaction = Sentry.start_transaction(op: 'http.server', name:)

        env['sentry.transaction'] = transaction
      end
    end

    base.after { env['sentry.transaction']&.finish }
  end
end
