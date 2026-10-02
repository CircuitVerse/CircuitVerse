Sentry.init do |config|
  # The DSN is injected via the SENTRY_DSN environment variable; it is no
  # longer hard-coded in the repository.
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Sample rates are configurable so production is not overwhelmed with
  # 100% of transactions and profiles. Both accept a value between 0.0 and 1.0.
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f
  config.profiles_sample_rate = ENV.fetch("SENTRY_PROFILES_SAMPLE_RATE", "0.1").to_f

  config.excluded_exceptions += ['ActionController::RoutingError', 'ActiveRecord::RecordNotFound']
end
