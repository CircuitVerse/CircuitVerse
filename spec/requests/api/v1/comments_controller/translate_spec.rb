# frozen_string_literal: true

require "rails_helper"
# Please keep in mind I am runnning this api temporarily on my github cloud resource
# Replace this URL with a production-ready service
# or self-hosted LibreTranslate instance for long-term use.
RSpec.describe Api::V1::CommentsController, "#translate", type: :request do
  describe "translate a comment" do
    # Setting up required test data like the other tests in this folder
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:comment) do
      FactoryBot.create(
        :commontator_comment, creator: creator, thread: project.commontator_thread, body: "Bonjour"
      ) # Creates a comment with the text "Bonjour"
    end

    # Scenario: Request without authentication
    context "when not authenticated" do
      before do
        put "/api/v1/comments/#{comment.id}/translate", as: :json # Attempt to translate without a token
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized) # Verifies a 401 Unauthorized status
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated" do
      let(:token) { get_auth_token(creator) }

      context "when translation is successful" do
        before do
          stub_request(:post, Rails.configuration.translate_api_endpoint)
            .with(
              body: {
                q: "Bonjour",
                source: "auto",
                target: "en",
                format: "text",
                api_key: "" # Empty since this is a temporary setup
              }.to_json,
              headers: { "Content-Type" => "application/json" }
            )
            .to_return(status: 200, body: { translatedText: "Hello" }.to_json,
                       headers: { "Content-Type" => "application/json" })

          put "/api/v1/comments/#{comment.id}/translate",
              headers: { Authorization: "Token #{token}" }, as: :json
        end

        it "returns the translated text" do
          expect(response).to have_http_status(:ok) # Verifies a 200 OK status
          expect(response.parsed_body["translated_text"]).to eq("Hello")
        end
      end

      # Sub-scenario: Translation fails
      context "when translation fails" do
        before do
          stub_request(:post, Rails.configuration.translate_api_endpoint)
            .to_return(status: 500, body: "Internal Server Error")

          put "/api/v1/comments/#{comment.id}/translate",
              headers: { Authorization: "Token #{token}" }, as: :json
        end

        it "returns an error" do
          expect(response).to have_http_status(:internal_server_error) # Verifies a 500 status
          expect(response.parsed_body).to have_jsonapi_error("Translation failed")
        end
      end
    end
  end
end
