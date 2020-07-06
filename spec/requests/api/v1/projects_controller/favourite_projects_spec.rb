# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#favourite_projects", type: :request do
  describe "list all starred projects" do
    let!(:user) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        get "/api/v1/projects/favourites", as: :json
      end

      it "returns status :not_authorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated" do
      before do
        # creates 3 project starred by user..
        FactoryBot.create_list(:project, 3, project_access_type: "Public").each do |p|
          FactoryBot.create(:star, user: user, project: p)
        end
        # creates 2 projects starred by some other user..
        FactoryBot.create_list(:project, 2, project_access_type: "Public").each do |p|
          FactoryBot.create(:star, user: FactoryBot.create(:user), project: p)
        end
        token = get_auth_token(user)
        get "/api/v1/projects/favourites",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all projects starred by user" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authenticated and includes author details" do
      before do
        # creates 3 project starred by user..
        FactoryBot.create_list(:project, 3, project_access_type: "Public").each do |p|
          FactoryBot.create(:star, user: user, project: p)
        end
        # creates 2 projects starred by some other user..
        FactoryBot.create_list(:project, 2, project_access_type: "Public").each do |p|
          FactoryBot.create(:star, user: FactoryBot.create(:user), project: p)
        end
        token = get_auth_token(user)
        get "/api/v1/projects/favourites?include=author",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all projects starred by user including author details" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects_with_author")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end
  end
end
