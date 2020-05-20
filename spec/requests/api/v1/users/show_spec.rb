# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, "#show", type: :request do
  describe "list a user" do
    let!(:user) { FactoryBot.create(:user) }

    context "when requested user does not exists" do
      before(:each) do
        get "/api/v1/users/0", as: :json
      end
      it "returns 404 :not_found and should have jsonapi errors" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when not authenticated" do
      before(:each) do
        get "/api/v1/users/#{user.id}", as: :json
      end
      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated" do
      before(:each) do
        token = get_auth_token(user)
        get "/api/v1/users/#{user.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns the correct user" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("user")
      end
    end
  end
end
