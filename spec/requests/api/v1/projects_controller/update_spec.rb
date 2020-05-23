# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#update", type: :request do
  describe "update specific project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user) }

    context "when not authenticated" do
      before do
        patch "/api/v1/projects/#{project.id}",
              params: { project: { name: "Project Name Updated" } }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when invalid parameters format" do
      before do
        token = get_auth_token(user)
        patch "/api/v1/projects/#{project.id}",
              headers: { "Authorization": "Token #{token}" },
              params: { name: "Project Name Updated" }
      end

      it "returns status bad_request" do
        expect(response).to have_http_status(400)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user tries to update other user's project details" do
      before do
        token = get_auth_token(random_user)
        patch "/api/v1/projects/#{project.id}",
              headers: { "Authorization": "Token #{token}" },
              params: { project: { name: "Project Name Updated" } }, as: :json
      end

      it "returns status :forbidden" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user tries to update own project details" do
      before do
        token = get_auth_token(user)
        patch "/api/v1/projects/#{project.id}",
              headers: { "Authorization": "Token #{token}" },
              params: { project: { name: "Project Name Updated" } }, as: :json
      end

      it "returns updated project details" do
        expect(response).to have_http_status(202)
        expect(response).to match_response_schema("project")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Project Name Updated")
      end
    end

    context "when authenticated user tries to update non existent project details" do
      before do
        token = get_auth_token(random_user)
        patch "/api/v1/projects/0",
              headers: { "Authorization": "Token #{token}" },
              params: { project: { name: "Project Name Updated" } }, as: :json
      end

      it "returns status :not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end
  end
end
