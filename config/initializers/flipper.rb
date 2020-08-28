# frozen_string_literal: true

require "flipper/adapters/redis"
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

Flipper::UI.configure do |config|
  config.fun = false
end
