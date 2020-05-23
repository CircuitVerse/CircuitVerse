# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#featured_circuits", type: :request do
  describe "list all featured projects" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project_one) { FactoryBot.create(:project, project_access_type: "Public", view: 1) }
    let!(:project_two) { FactoryBot.create(:project, project_access_type: "Public", view: 2) }
    let!(:featured_project_one) { FactoryBot.create(:featured_circuit, project: project_one) }
    let!(:featured_project_two) { FactoryBot.create(:featured_circuit, project: project_two) }

    context "when not authenticated" do
      before do
        get "/api/v1/projects/featured", as: :json
      end

      it "returns status :not_authorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all featured projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end

    context "when authenticated and checks for featured projects sorted by views" do
      it "returns all featured projects sorted by views in descending order" do
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "-view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([2, 1])
      end

      it "returns all featured projects sorted by views in ascending order" do
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([1, 2])
      end
    end
  end
end
