# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, "#index", type: :request do
  describe "list all users" do
    let!(:users_list) { FactoryBot.create_list(:user, 5) }

    context "when not authenticated" do
      before(:each) do
        get "/api/v1/users", as: :json
      end
      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated" do
      before(:each) do
        token = get_auth_token(users_list.first)
        get "/api/v1/users", headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns the correct users" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("users")
      end
    end
  end
end
