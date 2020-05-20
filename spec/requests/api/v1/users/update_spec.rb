# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, "#update", type: :request do
  describe "update a user" do
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
        patch "/api/v1/users/#{user.id}", params: { name: "Updated Name" }, as: :json
      end
      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated but not as the user to be updated" do
      before(:each) do
        token = get_auth_token(user)
        random_user = FactoryBot.create(:user)
        patch "/api/v1/users/#{random_user.id}",
        params: { name: "Updated Name" },
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns 403 :forbidden and should have jsonapi errors" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated as the user to be updated" do
      before(:each) do
        token = get_auth_token(user)
        patch "/api/v1/users/#{user.id}",
        params: { name: "Updated Name" },
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns the updated user" do
        expect(response).to have_http_status(202)
        expect(response).to match_response_schema("user")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Updated Name")
      end
    end
  end
end
