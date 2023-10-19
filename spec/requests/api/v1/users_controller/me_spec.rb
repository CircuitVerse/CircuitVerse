# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, "#me" do
  describe "GET logged in user" do
    let!(:user) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        get "/api/v1/me", as: :json
      end

      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated" do
      before do
        token = get_auth_token(user)
        get "/api/v1/me", headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the logged in user" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("user")
      end
    end
  end
end
