class Rack::Attack
  class Request < ::Rack::Request
    # Take remote IP from Cloudfare's headers instead of rev proxy IP
    def remote_ip
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] ||
                      env['action_dispatch.remote_ip'] ||
                      ip).to_s
    end
  end
  # Disable if DISABLE_RACK_ATTACK and if env is not production
  if !Rails.env.production?
    Rack::Attack.enabled = !ENV['DISABLE_RACK_ATTACK']
  end

  # Use redis for rack attack since config.cache_store is not set
  redis_client = Redis.new
  Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(redis_client)

  # Throttle all non asset requests
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.remote_ip unless req.path.start_with?('/assets')
  end

  # More agressively throttle login requests

  # Throttle by IP
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.remote_ip
    end
  end

  # Throttle by email
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['user']['email']
    end
  end

  self.throttled_response = lambda do |env|
   [ 429,  # status
     {},   # headers
     ['Too many requests, please try again later']] # body
  end
end