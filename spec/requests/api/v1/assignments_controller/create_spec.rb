# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#create" do
  describe "create/add an assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }

    context "when not authenticated" do
      before do
        post "/api/v1/groups/#{group.id}/assignments", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have edit_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/groups/#{group.id}/assignments",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to add assignments to non existent group" do
      before do
        token = get_auth_token(primary_mentor)
        post "/api/v1/groups/0/assignments",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to add assignment with invalid params" do
      before do
        token = get_auth_token(primary_mentor)
        post "/api/v1/groups/#{group.id}/assignments",
             headers: { Authorization: "Token #{token}" },
             params: { invalid: "invalid params" }, as: :json
      end

      it "returns status invalid request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to add assignments" do
      before do
        token = get_auth_token(primary_mentor)
        post "/api/v1/groups/#{group.id}/assignments",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns the created assignment" do
        expect(response).to have_http_status(:created)
        expect(response).to match_response_schema("assignment")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("test")
      end
    end

    def create_params
      {
        name: "test", deadline: Time.zone.now, description: "test description",
        grading_scale: "letter", restrictions: "[]"
      }
    end
  end
end
