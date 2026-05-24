# frozen_string_literal: true

if App.secrets.sentry_dsn.present?
  Sentry.init do |config|
    config.dsn = App.secrets.sentry_dsn
    config.breadcrumbs_logger = %i[sentry_logger monotonic_active_support_logger]
    config.background_worker_threads = 1
    config.send_default_pii = false
    config.traces_sample_rate = 0.0
  end
end
