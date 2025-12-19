# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/DescribeClass
RSpec.describe "trusted_proxies initializer" do
  let(:initializer_path) { Rails.root.join("config/initializers/trusted_proxies.rb") }

  before do
    # Store original config values
    @original_trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
    @original_ip_spoofing_check = Rails.configuration.action_dispatch.ip_spoofing_check
  end

  after do
    # Restore original config values
    Rails.configuration.action_dispatch.trusted_proxies = @original_trusted_proxies
    Rails.configuration.action_dispatch.ip_spoofing_check = @original_ip_spoofing_check
  end

  def reload_initializer
    load initializer_path
  end

  describe "trusted proxy configuration" do
    context "with default settings (no Cloudflare, no extra CIDRs)" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      # rubocop:disable RSpec/MultipleExpectations
      it "includes private and reserved IP ranges" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        # Check for localhost
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("127.0.0.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("::1")) }).to be true

        # Check for private networks
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("10.0.0.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("172.16.0.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("192.168.1.1")) }).to be true

        # Check for CGNAT
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("100.64.0.1")) }).to be true

        # Check for link-local
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("169.254.0.1")) }).to be true
      end
      # rubocop:enable RSpec/MultipleExpectations

      it "does not include Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        cloudflare_ip = IPAddr.new("162.158.86.173")

        expect(trusted_proxies.any? { |range| range.include?(cloudflare_ip) }).to be false
      end

      it "has at least 8 trusted proxy ranges (private/reserved only)" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        expect(trusted_proxies.size).to be >= 8
      end
    end

    context "when CF_PROXY_ENABLED=1" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("1")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      it "includes Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        # Check for known Cloudflare IPs
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("162.158.86.173")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("104.16.0.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("172.64.0.1")) }).to be true

        # Check for Cloudflare IPv6
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("2606:4700::1")) }).to be true
      end

      it "has more ranges than just private/reserved" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        # Private/reserved (8) + Cloudflare CIDRs (17) = 25
        expect(trusted_proxies.size).to be > 8
      end
    end

    context "when CF_PROXY_ENABLED=true" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("true")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      it "includes Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("162.158.86.173")) }).to be true
      end
    end

    context "when CF_PROXY_ENABLED=yes" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("yes")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      it "includes Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("162.158.86.173")) }).to be true
      end
    end

    context "when CF_PROXY_ENABLED=on" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("on")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      it "includes Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("162.158.86.173")) }).to be true
      end
    end

    context "when CF_PROXY_ENABLED=0" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("0")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
        reload_initializer
      end

      it "does not include Cloudflare CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies
        cloudflare_ip = IPAddr.new("162.158.86.173")

        expect(trusted_proxies.any? { |range| range.include?(cloudflare_ip) }).to be false
      end
    end

    context "when TRUSTED_PROXY_CIDRS contains valid CIDRs" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("203.0.113.0/24, 2001:db8::/32")
        reload_initializer
      end

      it "includes the extra CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("203.0.113.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("203.0.113.255")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("2001:db8::1")) }).to be true
      end
    end

    context "when TRUSTED_PROXY_CIDRS contains invalid CIDRs" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "")
                                     .and_return("203.0.113.0/24, invalid-cidr, 198.51.100.0/24")
        allow(Rails.logger).to receive(:warn)
        reload_initializer
      end

      it "includes valid CIDRs and skips invalid ones" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        # Valid CIDRs should be included
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("203.0.113.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("198.51.100.1")) }).to be true
      end

      it "logs a warning for invalid CIDRs" do
        expect(Rails.logger).to have_received(:warn).with(/Skipping invalid CIDR 'invalid-cidr'/)
      end
    end

    context "when TRUSTED_PROXY_CIDRS has empty entries" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("203.0.113.0/24, , 198.51.100.0/24")
        reload_initializer
      end

      it "skips empty entries and includes valid ones" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("203.0.113.1")) }).to be true
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("198.51.100.1")) }).to be true
      end
    end

    context "with CF_PROXY_ENABLED and TRUSTED_PROXY_CIDRS both set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("1")
        allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("203.0.113.0/24")
        reload_initializer
      end

      it "includes private, Cloudflare, and extra CIDRs" do
        trusted_proxies = Rails.configuration.action_dispatch.trusted_proxies

        # Private
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("10.0.0.1")) }).to be true

        # Cloudflare
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("162.158.86.173")) }).to be true

        # Extra
        expect(trusted_proxies.any? { |range| range.include?(IPAddr.new("203.0.113.1")) }).to be true
      end
    end
  end

  describe "ip_spoofing_check configuration" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("")
      allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
      reload_initializer
    end

    it "keeps ip_spoofing_check enabled" do
      expect(Rails.configuration.action_dispatch.ip_spoofing_check).to be true
    end
  end

  describe "logging" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("CF_PROXY_ENABLED", "").and_return("1")
      allow(ENV).to receive(:fetch).with("TRUSTED_PROXY_CIDRS", "").and_return("")
      allow(Rails.logger).to receive(:info)
    end

    it "logs the number of configured trusted proxy ranges" do
      reload_initializer
      expect(Rails.logger).to have_received(:info).with(/Configured \d+ trusted proxy ranges/)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
