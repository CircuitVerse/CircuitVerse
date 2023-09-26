# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#update" do
  describe "update specific group" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }

    context "when not authenticated" do
      before do
        patch "/api/v1/groups/#{group.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have edit_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/groups/#{group.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update details of non existent group" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/groups/0",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update group with invalid params" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/groups/#{group.id}",
              headers: { Authorization: "Token #{token}" },
              params: { invalid: "invalid" }, as: :json
      end

      it "returns status bad_request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to update group details" do
      before do
        FactoryBot.create(:group_member, user: user, group: group)
        token = get_auth_token(primary_mentor)
        patch "/api/v1/groups/#{group.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns the updated group details" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("group")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Test Group Updated")
      end
    end

    def update_params
      {
        name: "Test Group Updated"
      }
    end
  end
end
