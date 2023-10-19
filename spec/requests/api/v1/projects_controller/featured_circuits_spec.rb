# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#featured_circuits" do
  describe "list all featured projects" do
    context "when fetches all featured projects" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public").each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        get "/api/v1/projects/featured", as: :json
      end

      it "returns all featured projects" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(5)
      end
    end

    context "when includes author details" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public").each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        get "/api/v1/projects/featured?include=author", as: :json
      end

      it "returns all featured projects including author details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects_with_author")
        expect(response.parsed_body["data"].length).to eq(5)
      end
    end

    context "when checks for projects sorted in :ASC by views" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public", view: rand(10))
                  .each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        get "/api/v1/projects/featured",
            params: { sort: "view" }, as: :json
      end

      it "returns all projects sorted by views in ascending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort)
      end
    end

    context "when checks for projects sorted in :DESC by views" do
      before do
        FactoryBot.create_list(:project, 5, project_access_type: "Public", view: rand(10))
                  .each do |p|
          FactoryBot.create(:featured_circuit, project: p)
        end
        get "/api/v1/projects/featured",
            params: { sort: "-view" }, as: :json
      end

      it "returns all projects sorted by views in descending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq(views.sort.reverse)
      end
    end
  end
end
