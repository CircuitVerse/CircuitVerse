# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GradesController, "#update", type: :request do
  describe "create a grade" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
    let!(:assignment) { FactoryBot.create(:assignment, group: group, grading_scale: :letter) }
    let!(:project) { FactoryBot.create(:project, assignment: assignment) }
    let!(:grade) do
      FactoryBot.create(
        :grade, project: project, assignment: assignment,
                user_id: primary_mentor.id, grade: "A", remarks: "Good"
      )
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/grades/#{grade.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when not authorized to update assignment's grade" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/grades/#{grade.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update non existent grade" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/grades/0",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update grade with invalid params" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/grades/#{grade.id}",
              headers: { Authorization: "Token #{token}" },
              params: { invalid: "invalid" }, as: :json
      end

      it "returns status bad_request" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to update grade with different grading scale" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/grades/#{grade.id}",
              headers: { Authorization: "Token #{token}" },
              params: invalid_grading_scale_params, as: :json
      end

      it "returns status unprocessable_identity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized to update assignment's grade" do
      before do
        token = get_auth_token(primary_mentor)
        patch "/api/v1/grades/#{grade.id}",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
      end

      it "returns status accepted & grade details" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("grade")
        expect(response.parsed_body["data"]["attributes"]["grade"]).to eq("B")
      end
    end

    def update_params
      {
        grade: {
          grade: "B"
        }
      }
    end

    def invalid_grading_scale_params
      {
        grade: {
          grade: 100
        }
      }
    end
  end
end
