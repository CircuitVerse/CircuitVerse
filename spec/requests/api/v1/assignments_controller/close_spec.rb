# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#close", type: :request do
  describe "close specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
    let!(:member) { FactoryBot.create(:user) }
    let!(:assignment) { FactoryBot.create(:assignment, group: group, status: "open") }
    let!(:closed_assignment) { FactoryBot.create(:assignment, group: group, status: "closed") }

    context "when not authenticated" do
      before do
        patch "/api/v1/assignments/#{assignment.id}/close", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and does not have access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/assignments/#{assignment.id}/close",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to close non existent assignment" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/0/close",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as primary_mentor but assignment is already closed" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{closed_assignment.id}/close",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as primary_mentor and closes open assignment" do
      let!(:project) { FactoryBot.create(:project, assignment: assignment, author: member) }

      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/assignments/#{assignment.id}/close",
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "closes assignment & returns status accepted" do
        expect(response).to have_http_status(:accepted)
        expect(assignment.reload.status).to eq("closed")
      end

      it "freezes student projects as submissions" do
        submission = assignment.projects.find_by(author: member)
        expect(submission.project_submission).to be(true)
        expect(submission.forked_project_id).to eq(project.id)
        expect(project.reload.assignment_id).to be_nil
      end
    end
  end
end
