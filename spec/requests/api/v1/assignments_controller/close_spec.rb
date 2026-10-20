# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#close", type: :request do
  describe "close specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
    let!(:assignment) { FactoryBot.create(:assignment, group: group, status: "open") }
    let!(:closed_assignment) { FactoryBot.create(:assignment, group: group, status: "closed") }

    context "when not authenticated" do
      before do
        put "/api/v1/assignments/#{assignment.id}/close", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        put "/api/v1/assignments/#{assignment.id}/close",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as primary_mentor but assignment is already closed" do
      before do
        token = get_auth_token(primary_mentor)
        put "/api/v1/assignments/#{closed_assignment.id}/close",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to close assignment" do
      let!(:student) { FactoryBot.create(:user) }
      let!(:project) do
        FactoryBot.create(:project, assignment: assignment, author: student, project_submission: false)
      end

      before do
        token = get_auth_token(primary_mentor)
        put "/api/v1/assignments/#{assignment.id}/close",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns accepted status with close message" do
        put /api/v1/assignments/#{assignment.id}/close, headers: { Authorization: "Token #{token}" }, as: :json
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body["message"]).to eq("Assignment has been closed!")
      end

      it "closes assignment and freezes submissions" do
        put "/api/v1/assignments/#{assignment.id}/close", headers: { Authorization: "Token #{token}" }, as: :json
        assignment.reload
        project.reload
        expect(assignment.status).to eq("closed")
        expect(project.assignment_id).to be_nil

        submission = assignment.projects.find_by(author: student)
        expect(submission).to be_present
        expect(submission.project_submission).to be(true)
      end
    end
  end
end
