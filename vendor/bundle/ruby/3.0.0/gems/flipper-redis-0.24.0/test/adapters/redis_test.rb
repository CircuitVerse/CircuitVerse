require 'test_helper'
require 'flipper/adapters/redis'

class RedisTest < MiniTest::Test
  prepend Flipper::Test::SharedAdapterTests

  def setup
    url = ENV.fetch('REDIS_URL', 'redis://localhost:6379')
    client = Redis.new(url: url).tap(&:flushdb)
    @adapter = Flipper::Adapters::Redis.new(client)
  rescue Redis::CannotConnectError
    ENV['CI'] ? raise : skip('Redis not available')
  end
end
