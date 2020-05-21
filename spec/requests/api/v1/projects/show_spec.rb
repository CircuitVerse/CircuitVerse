# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#show", type: :request do
  describe "list specific project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:private_project) { FactoryBot.create(:project, author: user) }
    let!(:public_project) { FactoryBot.create(
      :project, project_access_type: "Public", author: user)
    }

    context "when not authenticated" do
      before(:each) do
        get "/api/v1/projects/#{public_project.id}", as: :json
      end
      it "should return status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated user fetches own public project's details" do
      before(:each) do
        token = get_auth_token(user)
        get "/api/v1/projects/#{public_project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return project details" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches own private project details" do
      before(:each) do
        token = get_auth_token(user)
        get "/api/v1/projects/#{private_project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return project details" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches another user's public project's details" do
      before(:each) do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{public_project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return project details" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches other user's private project" do
      before(:each) do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{private_project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return status :forbidden" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end
  end
end
