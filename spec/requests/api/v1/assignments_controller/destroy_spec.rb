# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#destroy", type: :request do
  describe "delete specific assignment" do
    let!(:primary_mentor) { FactoryBot.create(:user) }
    let!(:assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, primary_mentor: primary_mentor)
      )
    end

    context "when not authenticated" do
      before do
        delete "/api/v1/assignments/#{assignment.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have delete access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        delete "/api/v1/assignments/#{assignment.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to delete non existent assignment" do
      before do
        token = get_auth_token(primary_mentor)
        delete "/api/v1/assignments/0",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and has access to delete assignment" do
      before do
        token = get_auth_token(primary_mentor)
        delete "/api/v1/assignments/#{assignment.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "deletes assignment & return status no_content" do
        expect { Assignment.find(assignment.id) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
