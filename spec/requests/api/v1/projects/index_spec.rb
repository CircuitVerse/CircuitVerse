# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#index", type: :request do
  describe "list all projects" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:another_user) { FactoryBot.create(:user) }
    let!(:project_one) { FactoryBot.create(:project, project_access_type: "Public", view: 2) }
    let!(:project_two) { FactoryBot.create(:project, project_access_type: "Public", view: 3) }
    let!(:project_three) { FactoryBot.create(:project, project_access_type: "Public", view: 4) }
    let!(:public_project) do
      FactoryBot.create(
        :project, project_access_type: "Public", author: user
      )
    end
    let!(:private_project) { FactoryBot.create(:project, author: user) }

    context "when not authenticated" do
      before do
        get "/api/v1/projects", as: :json
      end

      it "returns all public projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(4)
      end
    end

    context "checks for projects sorted by views" do
      it "returns all public projects sorted by views in descending order" do
        get "/api/v1/projects", params: { sort: "-view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([4, 3, 2, 1])
      end

      it "returns all public projects sorted by views in ascending order" do
        get "/api/v1/projects", params: { sort: "view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([1, 2, 3, 4])
      end
    end

    context "when authenticated with user who has authored a project" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects", headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all public projects in additon to projects user is author of" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(5)
      end
    end

    context "when authenticated with user who hasn't authored a project" do
      before do
        token = get_auth_token(another_user)
        get "/api/v1/projects", headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns only all public projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(4)
      end
    end
  end
end
