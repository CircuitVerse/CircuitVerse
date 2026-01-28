# frozen_string_literal: true

# Sanitizes incoming proxy-related IP headers and normalizes the client IP
# when requests are routed through Cloudflare (or other trusted proxies).
#
# Why this exists
# - Some upstreams forward a non-standard, spoofable `Client-IP` header which
#   can conflict with the standard `X-Forwarded-For` chain and trigger
#   ActionDispatch::RemoteIp::IpSpoofAttackError.
# - When behind Cloudflare, the canonical client IP is provided via the
#   `CF-Connecting-IP` header, but only when the request actually came through
#   Cloudflare's edge network.
#
# What it does
# - Always drop `HTTP_CLIENT_IP` from the Rack env (it's non-standard and
#   frequently spoofed), preventing false-positive spoofing errors.
# - If CF_PROXY_ENABLED is set and the immediate peer (REMOTE_ADDR) is a
#   Cloudflare IP, replace REMOTE_ADDR and action_dispatch.remote_ip with
#   CF-Connecting-IP. This ensures Rails resolves the correct client IP.
#
# This middleware is inserted before ActionDispatch::RemoteIp in the stack.

require "ipaddr"

class ProxyIpSanitizer
  CLOUDFLARE_CIDRS = %w[
    173.245.48.0/20
    103.21.244.0/22
    103.22.200.0/22
    103.31.4.0/22
    141.101.64.0/18
    108.162.192.0/18
    190.93.240.0/20
    188.114.96.0/20
    197.234.240.0/22
    198.41.128.0/17
    162.158.0.0/15
    104.16.0.0/13
    104.24.0.0/14
    172.64.0.0/13
    131.0.72.0/22
    2400:cb00::/32
    2606:4700::/32
    2803:f800::/32
    2405:b500::/32
    2405:8100::/32
    2a06:98c0::/29
    2c0f:f248::/32
  ].map { |cidr| IPAddr.new(cidr) }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    # 1) Drop the non-standard, spoofable Client-IP header to avoid conflicts
    env.delete("HTTP_CLIENT_IP")

    # 2) If behind Cloudflare (opt-in via env flag), and the immediate peer
    #    is a Cloudflare edge, trust CF-Connecting-IP as the true client IP.
    if truthy_env?(ENV.fetch("CF_PROXY_ENABLED", nil)) && cloudflare_peer?(env["REMOTE_ADDR"])
      cf_ip = env["HTTP_CF_CONNECTING_IP"]
      if valid_ip?(cf_ip)
        env["action_dispatch.remote_ip"] = cf_ip
        env["REMOTE_ADDR"] = cf_ip
      end
    end

    @app.call(env)
  end

  private

    def cloudflare_peer?(addr)
      ip = ipaddr_from(addr)
      return false unless ip

      CLOUDFLARE_CIDRS.any? { |range| range.include?(ip) }
    end

    def ipaddr_from(addr)
      IPAddr.new(addr)
    rescue ArgumentError
      nil
    end

    def valid_ip?(addr)
      !!ipaddr_from(addr)
    end

    def truthy_env?(val)
      return false if val.nil?

      %w[1 true yes on].include?(val.to_s.strip.downcase)
    end
end
