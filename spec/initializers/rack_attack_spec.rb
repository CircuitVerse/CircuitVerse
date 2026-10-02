# frozen_string_literal: true

require "rails_helper"

describe Rack::Attack do
  describe ".throttled_responder" do
    # Rack::Attack only sets "rack.attack.match_data" on the request it
    # passes to the responder when the request was actually throttled, so
    # build a real request to exercise the same path.
    def respond_with(match_data)
      env = Rack::MockRequest.env_for("/projects")
      env["rack.attack.match_data"] = match_data unless match_data.nil?
      described_class.throttled_responder.call(Rack::Attack::Request.new(env))
    end

    it "responds with 429 and a plain-text body" do
      status, headers, body = respond_with(period: 300, epoch_time: 0)

      expect(status).to eq(429)
      expect(headers["Content-Type"]).to eq("text/plain")
      expect(body.first).to include("Too many requests")
    end

    it "reports the time left in the window rather than the whole period" do
      # 1_000 % 300 == 100, so 200s remain in this window, not the full 300.
      _status, headers, = respond_with(period: 300, epoch_time: 1_000)

      expect(headers["Retry-After"]).to eq("200")
    end

    it "reports the full period at the very start of a window" do
      _status, headers, = respond_with(period: 300, epoch_time: 1_200)

      expect(headers["Retry-After"]).to eq("300")
    end

    it "omits Retry-After when the throttle metadata is missing" do
      _status, headers, = respond_with(nil)

      expect(headers).not_to have_key("Retry-After")
    end
  end
end
