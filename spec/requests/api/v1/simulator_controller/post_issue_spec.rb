# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SimulatorController, type: :request do
  describe "POST /api/v1/simulator/post_issue/" do
    context "when SLACK_ISSUE_HOOK_URL is missing" do
      before do
        allow(ENV).to receive(:fetch).with("SLACK_ISSUE_HOOK_URL", nil).and_return(nil)
      end

      it "returns an internal server error status" do
        post "/api/v1/simulator/post_issue/", params: { text: "some text", circuit_data: "some data" }
        expect(response.status).to eq(422)
        expect(response.body).to include("Invalid or missing Slack webhook URL")
      end
    end

    context "when SLACK_ISSUE_HOOK_URL is present and returns reponse ok" do
      before do
        allow(ENV).to receive(:fetch).with("SLACK_ISSUE_HOOK_URL", nil).and_return("https://circuitverse.valid")
        stub_request(:post, "https://circuitverse.valid").to_return(status: 200, body: "", headers: {})
      end

      it "returns an ok status and success message" do
        post "/api/v1/simulator/post_issue/", params: { text: "some text", circuit_data: "some data" }
        expect(response.status).to eq(200)
        expect(response.body).to include("Issue submitted successfully")
      end
    end

    context "when SLACK_ISSUE_HOOK_URL is present but request fails with 404" do
      before do
        allow(ENV).to receive(:fetch).with("SLACK_ISSUE_HOOK_URL", nil).and_return("https://circuitverse.invalid")
        stub_request(:post, "https://circuitverse.invalid").to_return(status: 404, body: "", headers: {})
      end

      it "returns an ok status and success message" do
        post "/api/v1/simulator/post_issue/", params: { text: "some text", circuit_data: "some data" }
        expect(response.status).to eq(422)
        expect(response.body).to include("Failed to submit issue to Slack")
      end
    end
  end
end
