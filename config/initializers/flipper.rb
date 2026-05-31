# frozen_string_literal: true

require "redis"
require "flipper/adapters/redis"

# default flipper configuration
default_flipper_features = {
  recaptcha: false,
  forum: false,
  project_comments: true,
  lms_integration: true,
  vuesim: false,
  block_registration: false,
  active_storage_s3: true,
  contests: false,
  circuit_explore_page: false,
  yosys_local_gem: false
}

Flipper.configure do |config|
  config.default do
    client =
      if Rails.env.test?
        test_db = ENV.key?("FLIPPER_TEST_REDIS_DB") ? ENV["FLIPPER_TEST_REDIS_DB"].to_i : (1 + (ENV["TEST_ENV_NUMBER"] || "0").to_i)
        Redis.new(db: test_db)
      else
        ENV["REDIS_URL"] ? Redis.new(url: ENV["REDIS_URL"]) : Redis.new
      end

    Flipper.new(Flipper::Adapters::Redis.new(client))
  end
end

if ENV["DISABLE_FLIPPER"].blank? && !Rails.env.test?
  enabled_features = Flipper.features.map(&:name)
  default_flipper_features.each do |key, enabled|
    unless enabled_features.include?(key.to_s)
      Flipper.enable(key) if enabled
      Flipper.disable(key) unless enabled
    end
  end
end

Flipper::UI.configure do |config|
  config.fun = false
end
