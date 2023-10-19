# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#show" do
  describe "list specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
    let!(:group_member) do
      FactoryBot.create(:group_member, group: group, user: FactoryBot.create(:user))
    end
    let!(:assignment) do
      FactoryBot.create(:assignment, group: group, grading_scale: 1)
    end

    context "when not authenticated" do
      before do
        get "/api/v1/assignments/#{assignment.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have show_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/assignments/#{assignment.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to fetch details of non existent assignment" do
      before do
        token = get_auth_token(group_member.user)
        get "/api/v1/assignments/0",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to fetch assignment" do
      before do
        token = get_auth_token(group_member.user)
        get "/api/v1/assignments/#{assignment.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the group details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("assignment")
      end
    end

    context "when authorized and including projects" do
      before do
        # creates a project for the assignment..
        FactoryBot.create(:project, assignment: assignment)

        token = get_auth_token(primary_mentor)
        get "/api/v1/assignments/#{assignment.id}?include=projects",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns assignment with projects that belongs to the assignment" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("assignment_with_projects")
        expect(response.parsed_body["included"].length).to eq(1)
      end
    end

    context "when authorized and including grades" do
      before do
        # creates a project and corresponding grade for the assignment..
        project = FactoryBot.create(:project, assignment: assignment)
        FactoryBot.create(
          :grade, user_id: primary_mentor.id, assignment: assignment, project: project, grade: "A"
        )
        token = get_auth_token(primary_mentor)
        get "/api/v1/assignments/#{assignment.id}?include=grades",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns assignment with grades that belongs to the assignment" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("assignment_with_grades")
        expect(response.parsed_body["included"].length).to eq(1)
      end
    end
  end
end
