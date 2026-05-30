# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#update", type: :request do
  describe "update specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, primary_mentor: primary_mentor)
      )
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/assignments/#{assignment.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have edit_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/assignments/#{assignment.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update non existing assignments" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/0",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update using invalid params" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{assignment.id}",
              headers: { Authorization: "Token #{token}" },
              params: { invalid: "invalid params" }, as: :json
      end

      it "returns status invalid request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to update assignment" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{assignment.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns the updated assignment" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("assignment")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("test updated")
      end
    end

    def update_params
      {
        name: "test updated", deadline: Time.zone.now,
        description: "test description", restrictions: "[]"
      }
    end
  end
end
