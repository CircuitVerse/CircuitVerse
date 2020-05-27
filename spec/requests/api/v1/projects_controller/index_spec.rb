# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#index", type: :request do
  describe "list all projects" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:another_user) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        # creates 2 public projects
        FactoryBot.create_list(:project, 2, project_access_type: "Public")
        # creates 2 private projects
        FactoryBot.create_list(:project, 2)
        get "/api/v1/projects", as: :json
      end

      it "returns all public projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end

    context "when projects sorted by views" do
      before do
        # creates 4 public projects with random views
        FactoryBot.create_list(:project, 4, project_access_type: "Public", view: rand(10))
      end

      it "returns all public projects sorted by views in descending order" do
        get "/api/v1/projects", params: { sort: "-view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort.reverse)
      end

      it "returns all public projects sorted by views in ascending order" do
        get "/api/v1/projects", params: { sort: "view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort)
      end
    end

    context "when authenticated with user who has authored a project" do
      before do
        # creates 2 public projects
        FactoryBot.create_list(:project, 2, project_access_type: "Public")
        # creates a private project signed in user has authored
        FactoryBot.create(:project, author: user)

        token = get_auth_token(user)
        get "/api/v1/projects", headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all public projects in additon to projects user is author of" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authenticated with user who hasn't authored a project" do
      before do
        # creates 2 public projects
        FactoryBot.create_list(:project, 2, project_access_type: "Public")
        # creates a private project another user has authored
        FactoryBot.create(:project, author: another_user)

        token = get_auth_token(user)
        get "/api/v1/projects", headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns only all public projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end
  end
end
