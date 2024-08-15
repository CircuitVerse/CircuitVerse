require 'bundler/setup'
require 'redis-namespace'
require 'flipper/adapters/redis'

options = {url: 'redis://127.0.0.1:6379'}
if ENV['REDIS_URL']
  options[:url] = ENV['REDIS_URL']
end
client = Redis.new(options)
namespaced_client = Redis::Namespace.new(:flipper_namespace, redis: client)
adapter = Flipper::Adapters::Redis.new(namespaced_client)
flipper = Flipper.new(adapter)

# Register a few groups.
Flipper.register(:admins) { |thing| thing.admin? }
Flipper.register(:early_access) { |thing| thing.early_access? }

# Create a user class that has flipper_id instance method.
User = Struct.new(:flipper_id)

flipper[:stats].enable
flipper[:stats].enable_group :admins
flipper[:stats].enable_group :early_access
flipper[:stats].enable_actor User.new('25')
flipper[:stats].enable_actor User.new('90')
flipper[:stats].enable_actor User.new('180')
flipper[:stats].enable_percentage_of_time 15
flipper[:stats].enable_percentage_of_actors 45

flipper[:search].enable

print 'all keys: '
pp client.keys
# all keys: ["stats", "flipper_features", "search"]
puts

puts 'notice how all the keys are namespaced'
