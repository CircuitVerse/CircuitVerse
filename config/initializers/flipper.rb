require 'flipper/adapters/redis'
Flipper.configure do |config|
  config.default do
    client = Redis.new
    adapter = Flipper::Adapters::Redis.new(client)

    # pass adapter to handy DSL instance
    Flipper.new(adapter)
  end
end

Flipper::UI.configure do |config|
  config.fun = false
end
