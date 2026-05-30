# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupMembersController, "#create", type: :request do
  describe "create/add group members" do
    let!(:existing_user) { FactoryBot.create(:user, email: "test@test.com") }
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }

    context "when not authenticated" do
      before do
        post "/api/v1/groups/#{group.id}/members", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have edit_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/groups/#{group.id}/members",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to add members to non existent group" do
      before do
        token = get_auth_token(primary_mentor)
        post "/api/v1/groups/0/members",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to add group members" do
      before do
        token = get_auth_token(primary_mentor)
        post "/api/v1/groups/#{group.id}/members",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns the added, already_existing & invalid mails" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["added"]).to eq([existing_user.email])
        expect(response.parsed_body["pending"]).to eq(["newuser@test.com"])
        expect(response.parsed_body["invalid"]).to eq(["invalid"])
      end
    end

    def create_params
      {
        emails: "test@test.com, newuser@test.com, invalid"
      }
    end
  end
end
