require "rails_helper"

RSpec.describe Api::V1::SimulatorController, type: :request do
  describe "POST /api/v1/simulator/post_issue/" do
    context "when required params are present but SLACK_ISSUE_HOOK_URL is missing" do
      before do
        allow(ENV).to receive(:fetch).with("SLACK_ISSUE_HOOK_URL", nil).and_return(nil)
      end

      it "returns an internal server error status" do
        post "/api/v1/simulator/post_issue/", params: { text: "some text", circuit_data: "some data" }
        expect(response.status).to eq(500)
        expect(response.body).to include("Invalid or missing Slack webhook URL")
      end
    end

    context "when all required params are present and SLACK_ISSUE_HOOK_URL is valid" do
      before do
        allow(ENV).to receive(:fetch).with("SLACK_ISSUE_HOOK_URL", nil).and_return("https://circuitverse.test")
        stub_request(:post, "https://circuitverse.test").to_return(status: 200, body: "", headers: {})
      end

      it "returns an ok status and success message" do
        post "/api/v1/simulator/post_issue/", params: { text: "some text", circuit_data: "some data" }
        expect(response.status).to eq(200)
        expect(response.body).to include("Issue submitted successfully")
      end
    end
  end
end
