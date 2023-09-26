# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#reopen" do
  describe "reopen specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, primary_mentor: primary_mentor)
      )
    end
    let!(:open_assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, primary_mentor: primary_mentor), status: "open"
      )
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/assignments/#{assignment.id}/reopen", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/assignments/#{assignment.id}/reopen",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as primary_mentor but tries to open already opened assignment" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{open_assignment.id}/reopen",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to reopen non existent assignment" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/0/reopen",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to reopen assignment" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{assignment.id}/reopen",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "reopens assignment & return status accepted" do
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body["message"]).to eq("Assignment has been reopened!")
      end
    end
  end
end
