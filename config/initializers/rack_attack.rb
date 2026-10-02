# frozen_string_literal: true

class Rack::Attack
  class Request < ::Rack::Request
    # Take remote IP from Cloudfare's headers instead of rev proxy IP
    def remote_ip
      if ENV["CF_PROXY_ENABLED"]
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
        @remote_ip ||= (env["HTTP_CF_CONNECTING_IP"] ||
                        env["action_dispatch.remote_ip"] ||
                        ip).to_s
      else
        @remote_ip ||= ip
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

  ### Throttle Non Asset requests sitewide ###

  # Throttle by ip. Limit/period are tunable via ENV (audited defaults).
  # Parse strictly so a typo can't silently become 0, which would
  # throttle every request or break Rack::Attack's cache math.
  positive_int = lambda do |name, default|
    value = Integer(ENV.fetch(name, default))
    raise ArgumentError, "#{name} must be a positive integer" if value < 1

    value
  rescue ArgumentError, TypeError
    raise ArgumentError, "#{name} must be a positive integer"
  end

  throttle('throttle non asset requests by ip',
           limit: positive_int.call("RACK_ATTACK_SITEWIDE_LIMIT", 300),
           period: positive_int.call("RACK_ATTACK_SITEWIDE_PERIOD", 5.minutes)) do |req|
    req.remote_ip unless (req.path.start_with?('/assets') or req.path.start_with?('/uploads'))
  end

  ### Throttle logins ###

  # Throttle by IP
  throttle("throttle logins by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle by email
  throttle("throttle logins by email", limit: 5, period: 20.seconds) do |req|
    req.params.dig("user", "email")&.to_s&.downcase if req.path == "/users/sign_in" && req.post?
  end

  ### Throttle password resets ###

  # Throttle by IP
  throttle("throttle password resets by ip", limit: 5, period: 20.seconds) do |req|
    req.remote_ip if req.path == "/users/password" && req.post?
  end

  # Throttle by email
  throttle("throttle password resets by email", limit: 5, period: 20.seconds) do |req|
    req.params.dig("user", "email")&.to_s&.downcase if req.path == "/users/password" && req.post?
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

  # Rack::Attack 6.x passes a Rack::Attack::Request to the
  # throttled responder; the throttle metadata lives on its env.
  #
  # Report the time left in the current window, not the whole period: a
  # client that trips the limit near the end of a window should not be told
  # to back off for the full period again. This mirrors Rack::Attack's own
  # DEFAULT_THROTTLED_RESPONDER. If the metadata is missing we omit
  # Retry-After entirely, since advertising 0 would tell the client to retry
  # immediately and so defeat the throttle.
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    period = (match_data[:period] || 0).to_i
    epoch_time = (match_data[:epoch_time] || 0).to_i

    headers = { "Content-Type" => "text/plain" }
    headers["Retry-After"] = (period - (epoch_time % period)).to_s if period.positive?

    [429, headers, ["Too many requests, please try again later"]] # status, headers, body
  end
end
