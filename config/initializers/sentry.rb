# frozen_string_literal: true

if App.secrets.sentry_dsn.present?
  Sentry.init do |config|
    config.dsn = App.secrets.sentry_dsn
    config.breadcrumbs_logger = %i[sentry_logger monotonic_active_support_logger http_logger]
    config.profiles_sample_rate = 1.0
    config.background_worker_threads = 1
    config.send_default_pii = true

    config.traces_sampler = lambda do |sampling_context|
      next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

      transaction_context = sampling_context[:transaction_context]
      op = transaction_context[:op]
      transaction_name = transaction_context[:name]

      case op
      when /http/
        case transaction_name
        when /up/
          0.0
        else
          0.1
        end
      when /sidekiq/
        0.1
      else
        0.0
      end
    end
  end
end
