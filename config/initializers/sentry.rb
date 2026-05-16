# frozen_string_literal: true

if App.secrets.sentry_dsn.present?
  Sentry.init do |config|
    config.dsn = App.secrets.sentry_dsn
    config.breadcrumbs_logger = %i[sentry_logger monotonic_active_support_logger http_logger]
    config.profiles_sample_rate = 0.25
    config.background_worker_threads = 1
    config.send_default_pii = false

    config.traces_sampler = lambda do |sampling_context|
      next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

      transaction_context = sampling_context[:transaction_context]
      transaction_name = transaction_context[:name]

      case transaction_context[:op]
      when 'http.server'
        if transaction_name.start_with?('POST /telegram/webhook')
          1.0
        elsif transaction_name == 'POST /twitch/eventsub'
          0.25
        else
          0.0
        end
      when 'queue.sidekiq'
        transaction_name == 'Sidekiq/HandleTwitchEventJob' ? 0.25 : 1.0
      else
        0.0
      end
    end
  end
end
