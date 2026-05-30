# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#check_edit_access", type: :request do
  describe "check edit access" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user, name: "Test", project_access_type: "Private") }

    context "when not authenticated" do
      before do
        get "/api/v1/projects/#{project.id}/check_edit_access", as: :json
      end

      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user tries to check edit access of other user's project" do
      before do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{project.id}/check_edit_access",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user tries to check edit access of own project" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{project.id}/check_edit_access",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the logged in user details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("user")
      end
    end
  end
end
