# frozen_string_literal: true

class Rack::Attack
  class Request < ::Rack::Request
    # Take remote IP from Cloudfare's headers instead of rev proxy IP
    def remote_ip
      if ENV["CF_PROXY_DISABLED"]
        @remote_ip ||= ip
      else
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
        @remote_ip ||= (env["HTTP_CF_CONNECTING_IP"] ||
                        env["action_dispatch.remote_ip"] ||
                        ip).to_s
      end
    end

    # Hack to get JSON request params
    # Reads from the IO stream and resets the stream
    def json_params
      unless @json_params
        @json_params = JSON.parse env["rack.input"].read
        env["rack.input"].rewind
      end
      @json_params
    end
  end

  # Disable if DISABLE_RACK_ATTACK and if env is not production
  # Disabled in test env in environments/test.rb
  Rack::Attack.enabled = !ENV["DISABLE_RACK_ATTACK"] unless Rails.env.production?

  ### Throttle logins ###

  # Throttle by IP
  throttle("throttle logins by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle by email
  throttle("throttle logins by email", limit: 5, period: 20.seconds) do |req|
    req.params["user"]["email"].to_s.downcase if req.path == "/users/sign_in" && req.post?
  end

  ### Throttle password resets ###

  # Throttle by IP
  throttle("throttle password resets by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/users/password" && req.post?
  end

  # Throttle by email
  throttle("throttle password resets by email", limit: 5, period: 20.seconds) do |req|
    req.params["user"]["email"].to_s.downcase if req.path == "/users/password" && req.post?
  end

  ### Throttle logins on API ###

  # Throttle by IP
  throttle("throttle api logins by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Throttle by email
  throttle("throttle api logins by email", limit: 5, period: 20.seconds) do |req|
    req.json_params["email"].to_s.downcase if req.path == "/api/v1/auth/login" && req.post?
  end

  ### Throttle password resets on API ###

  # Throttle by IP
  throttle("throttle api password resets by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/api/v1/password/forgot" && req.post?
  end

  # Throttle by email
  throttle("throttle api password resets by email", limit: 5, period: 20.seconds) do |req|
    req.json_params["email"].to_s.downcase if req.path == "/api/v1/password/forgot" && req.post?
  end

  self.throttled_response = lambda do |_env|
    [429, # status
     {}, # headers
     ["Too many requests, please try again later"]] # body
  end
end
