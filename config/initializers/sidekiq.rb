# frozen_string_literal: true

redis_options = { db: ENV["BETA"] ? 1 : 0 }

if ENV.key?("SIDEKIQ_REDIS_NETWORK_TIMEOUT")
  network_timeout = Float(ENV["SIDEKIQ_REDIS_NETWORK_TIMEOUT"], exception: false)
  unless network_timeout&.finite? && network_timeout.positive?
    raise ArgumentError, "SIDEKIQ_REDIS_NETWORK_TIMEOUT must be a positive, finite number of seconds"
  end

  redis_options[:network_timeout] = network_timeout
end

Sidekiq.configure_client do |config|
  config.redis = redis_options.dup
end

Sidekiq.configure_server do |config|
  config.redis = redis_options.dup
end

