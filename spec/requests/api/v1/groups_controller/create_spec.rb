# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#create", type: :request do
  describe "create a group" do
    let!(:user) { create(:user) }

    context "when not authenticated" do
      before do
        post "/api/v1/groups", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to create group with invalid params" do
      before do
        token = get_auth_token(user)
        post "/api/v1/groups",
             headers: { Authorization: "Token #{token}" },
             params: { invalid: "invalid" }, as: :json
      end

      it "returns status bad_request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated to create a group" do
      before do
        token = get_auth_token(user)
        post "/api/v1/groups",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status created & group details" do
        expect(response).to have_http_status(:created)
        expect(response).to match_response_schema("group")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Test Group")
      end
    end

    def create_params
      {
        name: "Test Group"
      }
    end
  end
end
