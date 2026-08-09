# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::Score do
  include ActiveSupport::Testing::TimeHelpers

  let(:lineitem_url) { "https://canvas.example.com/api/lti/courses/1/line_items/42" }
  let(:token)        { "tok-1" }
  let(:posted)       { {} }

  def stub_http(success: true, status: 200)
    client = instance_double(HTTP::Client)
    allow(HTTP).to receive(:timeout).and_return(client)
    allow(client).to receive_messages(auth: client, headers: client)
    allow(client).to receive(:post) do |url, options|
      posted[:url] = url
      posted[:body] = JSON.parse(options[:body])
      instance_double(HTTP::Response,
                      status: instance_double(HTTP::Response::Status,
                                              success?: success, to_s: status.to_s))
    end
    client
  end

  def publish(url = lineitem_url, user_id: "lms-user-1", score_given: 8, score_maximum: 10)
    described_class.publish(url, token, user_id: user_id, score_given: score_given,
                                        score_maximum: score_maximum)
  end

  describe ".publish" do
    it "posts to the line item's scores endpoint" do
      stub_http
      expect(publish).to be(true)
      expect(posted[:url]).to eq("#{lineitem_url}/scores")
    end

    it "keeps a query the platform put on the line item url" do
      stub_http
      publish("#{lineitem_url}?type=assignment")

      expect(posted[:url]).to eq("#{lineitem_url}/scores?type=assignment")
    end

    it "sends the score against the maximum for the user" do
      stub_http
      publish

      expect(posted[:body]).to include("userId" => "lms-user-1", "scoreGiven" => 8,
                                       "scoreMaximum" => 10)
    end

    it "reports the activity as complete and fully graded" do
      stub_http
      publish

      expect(posted[:body]).to include("activityProgress" => "Completed",
                                       "gradingProgress" => "FullyGraded")
    end

    it "allows a partial score below the maximum" do
      stub_http
      publish(score_given: 3)

      expect(posted[:body]).to include("scoreGiven" => 3, "scoreMaximum" => 10)
    end

    it "allows a zero score rather than treating it as absent" do
      stub_http
      publish(score_given: 0)

      expect(posted[:body]["scoreGiven"]).to eq(0)
    end

    it "stamps the score in utc with sub-second precision" do
      stub_http
      travel_to(Time.utc(2026, 8, 9, 10, 30, 0)) { publish }

      expect(posted[:body]["timestamp"]).to eq("2026-08-09T10:30:00.000Z")
    end

    it "raises when the platform rejects the score" do
      stub_http(success: false, status: 422)
      expect { publish }.to raise_error(described_class::Error, /422/)
    end

    it "raises when the platform is unreachable" do
      client = instance_double(HTTP::Client)
      allow(HTTP).to receive(:timeout).and_return(client)
      allow(client).to receive_messages(auth: client, headers: client)
      allow(client).to receive(:post).and_raise(HTTP::ConnectionError, "connection refused")

      expect { publish }.to raise_error(described_class::Error, /refused/)
    end
  end
end
