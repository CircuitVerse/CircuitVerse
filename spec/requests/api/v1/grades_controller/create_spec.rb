# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GradesController, "#create", type: :request do
  describe "create a grade" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, mentor: mentor) }
    let!(:assignment) { FactoryBot.create(:assignment, group: group, grading_scale: :letter) }
    let!(:project) { FactoryBot.create(:project, assignment: assignment) }

    context "when not authenticated" do
      before do
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when not authorized to grade assignment" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades",
             headers: { "Authorization": "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to create grade with invalid params" do
      before do
        token = get_auth_token(mentor)
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades",
             headers: { "Authorization": "Token #{token}" },
             params: { "invalid": "invalid" }, as: :json
      end

      it "returns status bad_request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to create duplicate grade" do
      before do
        FactoryBot.create(
          :grade, project: project, assignment: assignment, \
                  user_id: mentor.id, grade: "A", remarks: "Good"
        )
        token = get_auth_token(mentor)
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades",
             headers: { "Authorization": "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status unprocessable_identity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to create grade with different grading scale" do
      before do
        token = get_auth_token(mentor)
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades",
             headers: { "Authorization": "Token #{token}" },
             params: invalid_grading_scale_params, as: :json
      end

      it "returns status unprocessable_identity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized to grade an assignment" do
      before do
        token = get_auth_token(mentor)
        post "/api/v1/assignments/#{assignment.id}/projects/#{project.id}/grades",
             headers: { "Authorization": "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status created & grade details" do
        expect(response).to have_http_status(:created)
        expect(response).to match_response_schema("grade")
        expect(response.parsed_body["data"]["attributes"]["grade"]).to eq("A")
      end
    end

    def create_params
      {
        "grade": {
          "grade": "A",
          "remarks": "Nice Work"
        }
      }
    end

    def invalid_grading_scale_params
      {
        "grade": {
          "grade": 100,
          "remarks": "Nice Work"
        }
      }
    end
  end
end
