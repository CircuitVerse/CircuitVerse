# frozen_string_literal: true

require "flipper/adapters/redis"

# default flipper configuration
default_flipper_features = {
  'recaptcha': false,
  'forum': false,
  'project_comments': true,
  'lms_integration': true,
}

Flipper.configure do |config|
  config.default do
    if Rails.env.test?
      adapter = Flipper::Adapters::Memory.new
    else
      client = Redis.new
      adapter = Flipper::Adapters::Redis.new(client)
    end

    # pass adapter to handy DSL instance
    Flipper.new(adapter)
  end
end

# set default flipper configuration
if !Rails.env.test? then
  enabled_features = Flipper.features.map { |feature| feature.name }
  default_flipper_features.each do |key, enabled|
    # If feature not set already then set to default
    unless enabled_features.include?(key.to_s)
      Flipper.enable(key) if enabled
      Flipper.disable(key) if !enabled
    end
  end
end

Flipper::UI.configure do |config|
  config.fun = false
end
