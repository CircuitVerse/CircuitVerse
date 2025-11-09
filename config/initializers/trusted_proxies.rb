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

  cloudflare = []
  if %w[1 true yes on].include?(ENV.fetch("CF_PROXY_ENABLED", "").to_s.downcase)
    cloudflare = %w[
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
    ].map { |cidr| IPAddr.new(cidr) }
  end

  extra = ENV.fetch("TRUSTED_PROXY_CIDRS", "").split(",").map(&:strip).reject(&:empty?).map { |cidr| IPAddr.new(cidr) }

  Rails.logger.info("[trusted_proxies] Configured #{(private_and_reserved + cloudflare + extra).size} trusted proxy ranges") if Rails.logger

  config.action_dispatch.trusted_proxies = private_and_reserved + cloudflare + extra

  # Keep Rails' spoofing check enabled. We rely on ProxyIpSanitizer to drop
  # the untrusted Client-IP header to avoid false positives.
  config.action_dispatch.ip_spoofing_check = true
end
