# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GradesController, "#destroy", type: :request do
  describe "delete specific grade" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, mentor: mentor) }
    let!(:assignment) { FactoryBot.create(:assignment, group: group, grading_scale: :letter) }
    let!(:project) { FactoryBot.create(:project, assignment: assignment) }
    let!(:grade) do
      FactoryBot.create(
        :grade, project: project, assignment: assignment, \
                user_id: mentor.id, grade: "A", remarks: "Good"
      )
    end

    context "when not authenticated" do
      before do
        delete "/api/v1/grades/#{grade.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have delete access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        delete "/api/v1/grades/#{grade.id}",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to delete non existent grade" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/grades/0",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized to delete grade" do
      before do
        token = get_auth_token(mentor)
        delete "/api/v1/grades/#{grade.id}",
               headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "delete group & return status no_content" do
        expect { Grade.find(grade.id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
