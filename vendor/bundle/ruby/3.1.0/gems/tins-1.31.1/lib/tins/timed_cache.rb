class TimedCache
  class Value < Struct.new(:value, :timestamp)
    def self.json_create(hash)
      new(*hash.values_at('value', 'timestamp'))
    end

    def as_json(*)
      super | { JSON.create_id => self.class.name }
    end
  end

  def initialize(name, ttl: 60, jitter: 1..5, &block)
    @name   = name
    @ttl    = ttl
    @jitter = jitter
    block or raise ArgumentError, 'block is required'
    @block = block
    @redis = Redis.new # RedisPool::Pool.connection(:timed_cache, configuration: :redis)
  end

  def namespaced(key)
    "timed_cache:#{key}"
  end

  def value
    now = Time.now
    if stored = stored_value
      if (now - @ttl).to_i >= stored.timestamp
        Thread.new {
          sleep @jitter
          if stored_value.timestamp <= stored.timestamp
            @redis.set namespaced(@name), new_value(now).to_json
          end
        }
      end
      stored.value
    else
      nv = new_value(now)
      @redis.set namespaced(@name), nv.to_json
      nv.value
    end
  end

  def new_value(now)
    Value.new(@block.(), now.to_i)
  end

  def stored_value
    @redis.get(namespaced(@name)).full? { |s| ::JSON.parse(s, create_additions: true) rescue nil }
  end
end
