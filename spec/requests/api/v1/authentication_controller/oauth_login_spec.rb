# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#oauth_login", type: :request do
  describe "oauth user login" do
    context "when user does not already exists" do
      before do
        post "/api/v1/oauth/login", params: oauth_params, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with invalid access token" do
      before do
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
          access_token: "ya29.a0AfH6SMB5cyjrwei-oi_TJ8Z4hTfw9v1tz-Ubm30AeWdzCpX9UHFY",
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
        create(:user, email: "test@test.com")
        post "/api/v1/oauth/login", params: oauth_params, as: :json
      end

      it "return status 202 and respond with token" do
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body).to have_key("token")
      end
    end

    def oauth_params
      {
        access_token: "ya29.a0AfH6SMB5cyjrwei-oi_TJ8Z4hTfw9v1tz-Ubm30AeWdzCpX9UHFY",
        provider: "google"
      }
    end
  end
end
