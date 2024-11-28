# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#login", type: :request do
  describe "user login" do
    let!(:user) { create(:user) }

    context "with invalid password" do
      before do
        post "/api/v1/auth/login", params: {
          email: user.email, password: "invalid"
        }, as: :json
      end

      it "return status 401 and should have jsonapi errors" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when user does not already exists" do
      before do
        new_user = build(:user)
        post "/api/v1/auth/login", params: {
          email: new_user.email, password: new_user.password
        }, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with valid params" do
      before do
        post "/api/v1/auth/login", params: {
          email: user.email, password: user.password
        }, as: :json
      end

      it "return status 202 and respond with token" do
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body).to have_key("token")
      end
    end
  end
end
