# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#oauth_signup", type: :request do
  describe "oauth user signup" do
    let!(:user) { FactoryBot.build(:user) }

    context "when user already exists" do
      before do
        existing_user = FactoryBot.create(:user)
        post "/api/v1/oauth/signup", params: oauth_signup_params(existing_user), as: :json
      end

      it "return status 409 and should have jsonapi errors" do
        expect(response).to have_http_status(409)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with valid params" do
      before do
        post "/api/v1/oauth/signup", params: oauth_signup_params(user), as: :json
      end

      it "return status 201 and respond with token" do
        expect(response).to have_http_status(201)
        expect(response.parsed_body).to have_key("token")
      end
    end

    def oauth_signup_params(user)
      {
        "uid": user.uid,
        "name": user.name,
        "email": user.email,
        "password": user.password,
        "provider": "google"
      }
    end
  end
end
