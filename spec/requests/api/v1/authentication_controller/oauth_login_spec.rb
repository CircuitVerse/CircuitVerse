# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe Api::V1::AuthenticationController, "#oauth_login", type: :request do
  describe "oauth user login" do
    context "when user does not already exists" do
      before do
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
          .with(headers: { 'Authorization' => "Bearer #{oauth_params[:access_token]}" })
          .to_return(
            status: 200,
            body: { email: "newuser@test.com", sub: "123456789" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        post "/api/v1/oauth/login", params: oauth_params, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with invalid access token" do
      before do
        stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
          .with(headers: { 'Authorization' => 'Bearer invalid_access_token' })
          .to_return(status: 401, body: "", headers: {})

        post "/api/v1/oauth/login", params: {
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
        post "/api/v1/oauth/login", params: {
          access_token: "dummy_token",
          provider: "unsupported_provider"
        }, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with valid params" do
      before do
        FactoryBot.create(:user, email: "test@test.com")

        stub_request(:get, "https://www.googleapis.com/oauth2/v3/userinfo")
          .with(headers: { 'Authorization' => "Bearer #{oauth_params[:access_token]}" })
          .to_return(
            status: 200,
            body: { email: "test@test.com", sub: "123456789" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        post "/api/v1/oauth/login", params: oauth_params, as: :json
      end

      it "return status 202 and respond with token" do
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body).to have_key("token")
      end
    end

    def oauth_params
      {
        access_token: "ya29.valid.mocked.token",
        provider: "google"
      }
    end
  end
end
