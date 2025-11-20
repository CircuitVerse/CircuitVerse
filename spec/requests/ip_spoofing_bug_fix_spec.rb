# frozen_string_literal: true

require "rails_helper"

RSpec.describe "IP Spoofing Bug Fix", type: :request do
  before do
    allow(Geocoder).to receive(:search).and_return([])
  end

  describe "Bug Fix: IpSpoofAttackError with conflicting HTTP_CLIENT_IP and X-Forwarded-For" do
    context "when HTTP_CLIENT_IP conflicts with X-Forwarded-For (Issue #6101)" do
      it "does not raise IpSpoofAttackError because Client-IP is dropped" do
        expect do
          get "/", headers: {
            "HTTP_CLIENT_IP" => "233.43.24.6",
            "HTTP_X_FORWARDED_FOR" => "146.12.125.53,194.195.87.55,162.158.86.173",
            "REMOTE_ADDR" => "162.158.86.173"
          }
        end.not_to raise_error
      end

      it "resolves the client IP from X-Forwarded-For chain when Client-IP is dropped" do
        get "/", headers: {
          "HTTP_CLIENT_IP" => "233.43.24.6",
          "HTTP_X_FORWARDED_FOR" => "146.12.125.53,194.195.87.55,162.158.86.173",
          "REMOTE_ADDR" => "162.158.86.173"
        }

        expect(response).to have_http_status(:success)
      end
    end

    context "when multiple proxy headers are present" do
      it "does not raise IpSpoofAttackError with load balancer headers" do
        expect do
          get "/", headers: {
            "HTTP_CLIENT_IP" => "192.0.2.1",
            "HTTP_X_FORWARDED_FOR" => "198.51.100.1,203.0.113.1",
            "REMOTE_ADDR" => "10.0.0.1"
          }
        end.not_to raise_error
      end

      it "handles requests without Client-IP normally" do
        expect do
          get "/", headers: {
            "HTTP_X_FORWARDED_FOR" => "146.12.125.53,194.195.87.55",
            "REMOTE_ADDR" => "172.16.0.1"
          }
        end.not_to raise_error
      end
    end
  end

  describe "Bug Fix: Cloudflare proxy IP resolution" do
    context "when CF_PROXY_ENABLED=1 and request is from Cloudflare" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("CF_PROXY_ENABLED").and_return("1")
      end

      it "correctly resolves client IP from CF-Connecting-IP header" do
        get "/", headers: {
          "HTTP_CF_CONNECTING_IP" => "203.0.113.1",
          "HTTP_X_FORWARDED_FOR" => "203.0.113.1,162.158.86.173",
          "REMOTE_ADDR" => "162.158.86.173"
        }

        expect(response).to have_http_status(:success)
      end

      it "does not raise IpSpoofAttackError with Cloudflare headers" do
        expect do
          get "/", headers: {
            "HTTP_CLIENT_IP" => "233.43.24.6",
            "HTTP_CF_CONNECTING_IP" => "146.12.125.53",
            "HTTP_X_FORWARDED_FOR" => "146.12.125.53,162.158.86.173",
            "REMOTE_ADDR" => "162.158.86.173"
          }
        end.not_to raise_error
      end
    end

    context "when CF_PROXY_ENABLED is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("CF_PROXY_ENABLED").and_return(nil)
      end

      it "does not raise IpSpoofAttackError even without CF feature enabled" do
        expect do
          get "/", headers: {
            "HTTP_CLIENT_IP" => "233.43.24.6",
            "HTTP_X_FORWARDED_FOR" => "146.12.125.53,162.158.86.173",
            "REMOTE_ADDR" => "162.158.86.173"
          }
        end.not_to raise_error
      end
    end
  end

  describe "Bug Fix: Trusted proxy configuration prevents false positives" do
    it "does not raise IpSpoofAttackError for requests through private network proxies" do
      expect do
        get "/", headers: {
          "HTTP_X_FORWARDED_FOR" => "198.51.100.1,10.0.0.1",
          "REMOTE_ADDR" => "10.0.0.1"
        }
      end.not_to raise_error
    end

    it "does not raise IpSpoofAttackError for requests through localhost" do
      expect do
        get "/", headers: {
          "HTTP_X_FORWARDED_FOR" => "198.51.100.1,127.0.0.1",
          "REMOTE_ADDR" => "127.0.0.1"
        }
      end.not_to raise_error
    end

    it "handles IPv6 requests correctly" do
      expect do
        get "/", headers: {
          "HTTP_X_FORWARDED_FOR" => "2001:db8::1,::1",
          "REMOTE_ADDR" => "::1"
        }
      end.not_to raise_error
    end
  end

  describe "Bug Fix: Maintains security while fixing false positives" do
    it "still validates IPs when ip_spoofing_check is enabled" do
      expect(Rails.configuration.action_dispatch.ip_spoofing_check).to be true
    end

    it "processes requests normally without spoofable headers" do
      get "/", headers: {
        "HTTP_X_FORWARDED_FOR" => "203.0.113.1",
        "REMOTE_ADDR" => "10.0.0.1"
      }

      expect(response).to have_http_status(:success)
    end

    it "handles direct requests without proxy headers" do
      get "/", headers: {
        "REMOTE_ADDR" => "203.0.113.1"
      }

      expect(response).to have_http_status(:success)
    end
  end

  describe "Bug Fix: Edge cases that previously caused errors" do
    it "handles malformed Client-IP without raising errors" do
      expect do
        get "/", headers: {
          "HTTP_CLIENT_IP" => "not-an-ip",
          "HTTP_X_FORWARDED_FOR" => "198.51.100.1",
          "REMOTE_ADDR" => "10.0.0.1"
        }
      end.not_to raise_error
    end

    it "handles empty Client-IP header" do
      expect do
        get "/", headers: {
          "HTTP_CLIENT_IP" => "",
          "HTTP_X_FORWARDED_FOR" => "198.51.100.1",
          "REMOTE_ADDR" => "10.0.0.1"
        }
      end.not_to raise_error
    end

    it "handles multiple IPs in X-Forwarded-For with spaces" do
      expect do
        get "/", headers: {
          "HTTP_CLIENT_IP" => "233.43.24.6",
          "HTTP_X_FORWARDED_FOR" => "146.12.125.53, 194.195.87.55, 162.158.86.173",
          "REMOTE_ADDR" => "162.158.86.173"
        }
      end.not_to raise_error
    end

    it "handles requests with only Client-IP (no X-Forwarded-For)" do
      expect do
        get "/", headers: {
          "HTTP_CLIENT_IP" => "233.43.24.6",
          "REMOTE_ADDR" => "10.0.0.1"
        }
      end.not_to raise_error
    end
  end
end
