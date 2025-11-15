# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProxyIpSanitizer do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:middleware) { described_class.new(app) }

  describe "#call" do
    context "when HTTP_CLIENT_IP is present" do
      it "removes HTTP_CLIENT_IP header" do
        env = {
          "HTTP_CLIENT_IP" => "233.43.24.6",
          "REMOTE_ADDR" => "10.0.0.1"
        }

        middleware.call(env)

        expect(env).not_to have_key("HTTP_CLIENT_IP")
      end

      it "prevents IP spoofing attack error by dropping conflicting Client-IP" do
        env = {
          "HTTP_CLIENT_IP" => "233.43.24.6",
          "HTTP_X_FORWARDED_FOR" => "146.12.125.53,194.195.87.55,162.158.86.173",
          "REMOTE_ADDR" => "162.158.86.173"
        }

        middleware.call(env)

        expect(env).not_to have_key("HTTP_CLIENT_IP")
      end
    end

    context "when CF_PROXY_ENABLED is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("CF_PROXY_ENABLED").and_return(cf_proxy_value)
      end

      context "with truthy value (1)" do
        let(:cf_proxy_value) { "1" }

        it "replaces REMOTE_ADDR with CF-Connecting-IP when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "162.158.86.173", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "146.12.125.53"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("146.12.125.53")
          expect(env["action_dispatch.remote_ip"]).to eq("146.12.125.53")
        end

        it "replaces REMOTE_ADDR with CF-Connecting-IP for IPv6 Cloudflare IP" do
          env = {
            "REMOTE_ADDR" => "2606:4700:10::6816:123", # Cloudflare IPv6
            "HTTP_CF_CONNECTING_IP" => "2001:db8::1"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("2001:db8::1")
          expect(env["action_dispatch.remote_ip"]).to eq("2001:db8::1")
        end

        it "does not replace REMOTE_ADDR when peer is not Cloudflare IP" do
          env = {
            "REMOTE_ADDR" => "203.0.113.1", # Non-Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "146.12.125.53"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("203.0.113.1")
          expect(env["action_dispatch.remote_ip"]).to be_nil
        end

        it "does not replace REMOTE_ADDR when CF-Connecting-IP is invalid" do
          env = {
            "REMOTE_ADDR" => "162.158.86.173", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "not-an-ip"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("162.158.86.173")
          expect(env["action_dispatch.remote_ip"]).to be_nil
        end

        it "does not replace REMOTE_ADDR when CF-Connecting-IP is missing" do
          env = {
            "REMOTE_ADDR" => "162.158.86.173" # Cloudflare IP
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("162.158.86.173")
          expect(env["action_dispatch.remote_ip"]).to be_nil
        end
      end

      context "with truthy value (true)" do
        let(:cf_proxy_value) { "true" }

        it "replaces REMOTE_ADDR with CF-Connecting-IP when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "104.16.0.1", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "192.0.2.1"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("192.0.2.1")
          expect(env["action_dispatch.remote_ip"]).to eq("192.0.2.1")
        end
      end

      context "with truthy value (yes)" do
        let(:cf_proxy_value) { "yes" }

        it "replaces REMOTE_ADDR with CF-Connecting-IP when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "104.24.0.1", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "198.51.100.1"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("198.51.100.1")
          expect(env["action_dispatch.remote_ip"]).to eq("198.51.100.1")
        end
      end

      context "with truthy value (on)" do
        let(:cf_proxy_value) { "on" }

        it "replaces REMOTE_ADDR with CF-Connecting-IP when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "172.64.0.1", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "203.0.113.1"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("203.0.113.1")
          expect(env["action_dispatch.remote_ip"]).to eq("203.0.113.1")
        end
      end

      context "with falsy value (0)" do
        let(:cf_proxy_value) { "0" }

        it "does not replace REMOTE_ADDR even when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "162.158.86.173", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "146.12.125.53"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("162.158.86.173")
          expect(env["action_dispatch.remote_ip"]).to be_nil
        end
      end

      context "with falsy value (false)" do
        let(:cf_proxy_value) { "false" }

        it "does not replace REMOTE_ADDR even when peer is Cloudflare" do
          env = {
            "REMOTE_ADDR" => "162.158.86.173", # Cloudflare IP
            "HTTP_CF_CONNECTING_IP" => "146.12.125.53"
          }

          middleware.call(env)

          expect(env["REMOTE_ADDR"]).to eq("162.158.86.173")
          expect(env["action_dispatch.remote_ip"]).to be_nil
        end
      end
    end

    context "when CF_PROXY_ENABLED is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("CF_PROXY_ENABLED").and_return(nil)
      end

      it "does not replace REMOTE_ADDR even when peer is Cloudflare" do
        env = {
          "REMOTE_ADDR" => "162.158.86.173", # Cloudflare IP
          "HTTP_CF_CONNECTING_IP" => "146.12.125.53"
        }

        middleware.call(env)

        expect(env["REMOTE_ADDR"]).to eq("162.158.86.173")
        expect(env["action_dispatch.remote_ip"]).to be_nil
      end
    end

    it "calls the next middleware in the stack" do
      env = { "REMOTE_ADDR" => "10.0.0.1" }
      app_double = double("app") # rubocop:disable RSpec/VerifiedDoubles
      middleware = described_class.new(app_double)

      allow(app_double).to receive(:call).with(env)
      middleware.call(env)
      expect(app_double).to have_received(:call).with(env)
    end
  end

  describe "#cloudflare_peer?" do
    let(:middleware_instance) { middleware }

    it "returns true for IPv4 Cloudflare CIDR" do
      expect(middleware_instance.send(:cloudflare_peer?, "162.158.86.173")).to be true
      expect(middleware_instance.send(:cloudflare_peer?, "104.16.0.1")).to be true
      expect(middleware_instance.send(:cloudflare_peer?, "172.64.0.1")).to be true
    end

    it "returns true for IPv6 Cloudflare CIDR" do
      expect(middleware_instance.send(:cloudflare_peer?, "2606:4700::1")).to be true
      expect(middleware_instance.send(:cloudflare_peer?, "2400:cb00::1")).to be true
    end

    it "returns false for non-Cloudflare IPs" do
      expect(middleware_instance.send(:cloudflare_peer?, "203.0.113.1")).to be false
      expect(middleware_instance.send(:cloudflare_peer?, "192.0.2.1")).to be false
      expect(middleware_instance.send(:cloudflare_peer?, "2001:db8::1")).to be false
    end

    it "returns false for invalid IP addresses" do
      expect(middleware_instance.send(:cloudflare_peer?, "not-an-ip")).to be false
      expect(middleware_instance.send(:cloudflare_peer?, "999.999.999.999")).to be false
      expect(middleware_instance.send(:cloudflare_peer?, nil)).to be false
    end
  end

  describe "#valid_ip?" do
    let(:middleware_instance) { middleware }

    it "returns true for valid IPv4 addresses" do
      expect(middleware_instance.send(:valid_ip?, "192.0.2.1")).to be true
      expect(middleware_instance.send(:valid_ip?, "10.0.0.1")).to be true
    end

    it "returns true for valid IPv6 addresses" do
      expect(middleware_instance.send(:valid_ip?, "2001:db8::1")).to be true
      expect(middleware_instance.send(:valid_ip?, "::1")).to be true
    end

    it "returns false for invalid IP addresses" do
      expect(middleware_instance.send(:valid_ip?, "not-an-ip")).to be false
      expect(middleware_instance.send(:valid_ip?, "999.999.999.999")).to be false
      expect(middleware_instance.send(:valid_ip?, "")).to be false
      expect(middleware_instance.send(:valid_ip?, nil)).to be false
    end
  end

  describe "#truthy_env?" do
    let(:middleware_instance) { middleware }

    it "returns true for '1'" do
      expect(middleware_instance.send(:truthy_env?, "1")).to be true
    end

    it "returns true for 'true'" do
      expect(middleware_instance.send(:truthy_env?, "true")).to be true
    end

    it "returns true for 'yes'" do
      expect(middleware_instance.send(:truthy_env?, "yes")).to be true
    end

    it "returns true for 'on'" do
      expect(middleware_instance.send(:truthy_env?, "on")).to be true
    end

    it "returns true for uppercase variants" do
      expect(middleware_instance.send(:truthy_env?, "TRUE")).to be true
      expect(middleware_instance.send(:truthy_env?, "YES")).to be true
      expect(middleware_instance.send(:truthy_env?, "ON")).to be true
    end

    it "returns true for values with whitespace" do
      expect(middleware_instance.send(:truthy_env?, " 1 ")).to be true
      expect(middleware_instance.send(:truthy_env?, " true ")).to be true
    end

    it "returns false for '0'" do
      expect(middleware_instance.send(:truthy_env?, "0")).to be false
    end

    it "returns false for 'false'" do
      expect(middleware_instance.send(:truthy_env?, "false")).to be false
    end

    it "returns false for 'no'" do
      expect(middleware_instance.send(:truthy_env?, "no")).to be false
    end

    it "returns false for nil" do
      expect(middleware_instance.send(:truthy_env?, nil)).to be false
    end

    it "returns false for empty string" do
      expect(middleware_instance.send(:truthy_env?, "")).to be false
    end

    it "returns false for random strings" do
      expect(middleware_instance.send(:truthy_env?, "random")).to be false
    end
  end

  describe "CLOUDFLARE_CIDRS" do
    it "is frozen" do
      expect(described_class::CLOUDFLARE_CIDRS).to be_frozen
    end

    it "contains IPAddr objects" do
      expect(described_class::CLOUDFLARE_CIDRS).to all(be_a(IPAddr))
    end

    it "includes known Cloudflare IPv4 ranges" do
      ipv4_cidrs = described_class::CLOUDFLARE_CIDRS.select(&:ipv4?)
      expect(ipv4_cidrs).not_to be_empty

      # Check that specific IPs fall within the expected ranges
      expect(ipv4_cidrs.any? { |range| range.include?(IPAddr.new("173.245.48.1")) }).to be true
      expect(ipv4_cidrs.any? { |range| range.include?(IPAddr.new("162.158.0.1")) }).to be true
      expect(ipv4_cidrs.any? { |range| range.include?(IPAddr.new("104.16.0.1")) }).to be true
    end

    it "includes known Cloudflare IPv6 ranges" do
      ipv6_cidrs = described_class::CLOUDFLARE_CIDRS.select(&:ipv6?)
      expect(ipv6_cidrs).not_to be_empty

      # Check that specific IPs fall within the expected ranges
      expect(ipv6_cidrs.any? { |range| range.include?(IPAddr.new("2400:cb00::1")) }).to be true
      expect(ipv6_cidrs.any? { |range| range.include?(IPAddr.new("2606:4700::1")) }).to be true
    end
  end
end
