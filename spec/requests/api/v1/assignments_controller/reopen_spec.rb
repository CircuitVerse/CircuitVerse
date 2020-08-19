# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#reopen", type: :request do
  describe "reopen specific assignment" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, mentor: mentor)
      )
    end
    let!(:open_assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, mentor: mentor), status: "open"
      )
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/assignments/#{assignment.id}/reopen", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/assignments/#{assignment.id}/reopen",
              headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as mentor but tries to open already opened assignment" do
      before do
        token = get_auth_token(mentor)
        patch "/api/v1/assignments/#{open_assignment.id}/reopen",
              headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status conflict" do
        expect(response).to have_http_status(409)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to reopen non existent assignment" do
      before do
        token = get_auth_token(mentor)
        patch "/api/v1/assignments/0/reopen",
              headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to reopen assignment" do
      before do
        token = get_auth_token(mentor)
        patch "/api/v1/assignments/#{assignment.id}/reopen",
              headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "reopens assignment & return status accepted" do
        expect(response).to have_http_status(202)
        expect(response.parsed_body["message"]).to eq("Assignment has been reopened!")
      end
    end
  end
end
