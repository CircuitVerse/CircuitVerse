# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe Api::V1::AuthenticationController, "#oauth_signup", type: :request do
  describe "oauth user signup" do
    context "when user already exists" do
      before do
        FactoryBot.create(:user, email: "test@test.com")
        post "/api/v1/oauth/signup", params: oauth_params, as: :json
      end

      it "return status 409 and should have jsonapi errors" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with invalid access token" do
      before do
        stub_google_userinfo_failure("invalid_access_token")
        post "/api/v1/oauth/signup", params: {
          access_token: "invalid_access_token",
          provider: "google"
        }, as: :json
      end

      it "return status 401 and should have jsonapi errors" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with unsupported provider type" do
      before do
        post "/api/v1/oauth/signup", params: {
          access_token: "ya29.a0AfH6SMB5cyjrwei-oi_TJ8Z4hTfw9v1tz-Ubm30AeWdzCpX9UHFY",
          provider: "unsupported_provider"
        }, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with empty email & valid provider" do
      before do
        stub_google_userinfo_response("empty_email_token", email: "")
        post "/api/v1/oauth/signup", params: {
          access_token: "empty_email_token",
          provider: "google"
        }, as: :json
      end

      it "return status 422 and should have jsonapi error with detail 'Email can't be blank'" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_error("Email can't be blank")
      end
    end

    context "with valid params" do
      before do
        stub_google_userinfo_response
        post "/api/v1/oauth/signup", params: oauth_params, as: :json
      end

      it "return status 201 and respond with token" do
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to have_key("token")
      end
    end

    context "when registration is blocked" do
      before do
        allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(true)
        stub_google_userinfo_response
        post "/api/v1/oauth/signup", params: oauth_params, as: :json
      end

      it "returns an error with status 403 and a message" do
        expect(response).to have_http_status(:forbidden)
        parsed_response = response.parsed_body
        expect(parsed_response["errors"]).to eq([
          {
            "detail" => "Registration is currently blocked",
            "status" => 403,
            "title" => "Registration is currently blocked"
          }
        ])
      end
    end

    def oauth_params
      {
        access_token: "ya29.a0AfH6SMB5cyjrwei-oi_TJ8Z4hTfw9v1tz-Ubm30AeWdzCpX9UHFY",
        provider: "google"
      }
    end

    # Helper to stub a successful response from Google
    def stub_google_userinfo_response(token = "ya29.a0AfH6SMB5cyjrwei-oi_TJ8Z4hTfw9v1tz-Ubm30AeWdzCpX9UHFY", email: "newuser@example.com")
      stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
        .with(headers: {
          'Authorization' => "Bearer #{token}"
        }).to_return(
          status: 200,
          body: {
            email: email,
            name: "New User",
            sub: "google-oauth2|1234567890"
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Helper to stub a failed token validation
    def stub_google_userinfo_failure(token)
      stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
        .with(headers: {
          'Authorization' => "Bearer #{token}"
        }).to_return(
          status: 401,
          body: {
            error: "invalid_token",
            error_description: "Invalid Value"
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
  end
end
