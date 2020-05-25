# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#featured_circuits", type: :request do
  describe "list all featured projects" do
    let!(:user) { FactoryBot.create(:user) }

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
        FactoryBot.create_list(:project, 5, project_access_type: "Public").each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all featured projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(5)
      end
    end

    context "when authenticated and checks for projects sorted in :ASC by views" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public", view: rand(10))
                  .each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "view" }, as: :json
      end

      it "returns all projects sorted by views in ascending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort)
      end
    end

    context "when authenticated and checks for projects sorted in :DESC by views" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public", view: rand(10))
                  .each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        token = get_auth_token(user)
        get "/api/v1/projects/featured",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "-view" }, as: :json
      end

      it "returns all projects sorted by views in descending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort.reverse)
      end
    end
  end
end
