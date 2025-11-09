# frozen_string_literal: true

# Configure which proxy IP ranges Rails should trust when resolving the
# originating client IP address. This avoids false-positive
# ActionDispatch::RemoteIp::IpSpoofAttackError when requests traverse
# multiple legitimate proxies (CDN, load balancer, ingress, etc.).
#
# You can append additional ranges via TRUSTED_PROXY_CIDRS env var, e.g.:
#   TRUSTED_PROXY_CIDRS="203.0.113.0/24, 2001:db8::/32"
#
# If you run behind Cloudflare, set CF_PROXY_ENABLED=1 in the environment so
# Cloudflare CIDRs are added here and the ProxyIpSanitizer middleware will
# also normalize the client IP using CF-Connecting-IP.

require "ipaddr"

Rails.application.configure do
  private_and_reserved = %w[
    127.0.0.0/8
    ::1
    10.0.0.0/8
    172.16.0.0/12
    192.168.0.0/16
    100.64.0.0/10
    169.254.0.0/16
    fc00::/7
    fe80::/10
  ].map { |cidr| IPAddr.new(cidr) }

  cloudflare = if %w[1 true yes on].include?(ENV.fetch("CF_PROXY_ENABLED", "").to_s.downcase)
    ProxyIpSanitizer::CLOUDFLARE_CIDRS
  else
    []
  end

  extra = ENV.fetch("TRUSTED_PROXY_CIDRS", "").split(",").map(&:strip).reject(&:empty?).filter_map do |cidr|
    IPAddr.new(cidr)
  rescue IPAddr::InvalidAddressError, ArgumentError => e
    Rails.logger&.warn("[trusted_proxies] Skipping invalid CIDR '#{cidr}': #{e.message}")
    nil
  end

  Rails.logger.info("[trusted_proxies] Configured #{(private_and_reserved + cloudflare + extra).size} trusted proxy ranges") if Rails.logger

  config.action_dispatch.trusted_proxies = private_and_reserved + cloudflare + extra

  # Keep Rails' spoofing check enabled. We rely on ProxyIpSanitizer to drop
  # the untrusted Client-IP header to avoid false positives.
  config.action_dispatch.ip_spoofing_check = true
end
