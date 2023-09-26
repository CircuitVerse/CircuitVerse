# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#show" do
  describe "list specific project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:private_project) { FactoryBot.create(:project, author: user) }
    let!(:public_project) do
      FactoryBot.create(:project, project_access_type: "Public", author: user)
    end

    context "when unauthenticated user fetches public project details" do
      before do
        get "/api/v1/projects/#{public_project.id}", as: :json
      end

      it "returns project details with is_starred as nil" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
        expect(response.parsed_body["data"]["attributes"]["is_starred"]).to be_nil
      end
    end

    context "when unauthenticated user fetches public project with author details" do
      before do
        get "/api/v1/projects/#{public_project.id}?include=author", as: :json
      end

      it "returns project details including author details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project_with_author")
      end
    end

    context "when unauthenticated user fetches public project with collaborators" do
      before do
        # Adds random user as a collaborator to public_project
        FactoryBot.create(:collaboration, user: FactoryBot.create(:user), project: public_project)
        get "/api/v1/projects/#{public_project.id}?include=collaborators", as: :json
      end

      it "returns project details including collaborators" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project_with_collaborators")
      end
    end

    context "when unauthenticated user fetches private project details" do
      before do
        get "/api/v1/projects/#{private_project.id}", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user fetches own public project's details" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{public_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns project details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches own private project details" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{private_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns project details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches another user's public project's details" do
      before do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{public_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns project details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
      end
    end

    context "when authenticated user fetches other user's private project" do
      before do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{private_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status :forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & fetches starred project" do
      before do
        token = get_auth_token(user)
        FactoryBot.create(:star, user_id: user.id, project_id: public_project.id)
        get "/api/v1/projects/#{public_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns project details with is_starred attr to be true" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
        expect(response.parsed_body["data"]["attributes"]["is_starred"]).to be true
      end
    end

    context "when authenticated & fetches unstarred project" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{public_project.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns project details with is_starred attr to be false" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
        expect(response.parsed_body["data"]["attributes"]["is_starred"]).to be false
      end
    end
  end
end
