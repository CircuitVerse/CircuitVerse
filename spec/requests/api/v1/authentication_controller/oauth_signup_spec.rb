# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#oauth_signup" do
  describe "oauth user signup" do
    context "when user already exists" do
      before do
        # creates a user with specified email
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
        post "/api/v1/oauth/signup", params: oauth_params, as: :json
      end

      it "return status 201 and respond with token" do
        expect(response).to have_http_status(:created)
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
