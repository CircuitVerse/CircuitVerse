# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#create_fork", type: :request do
  describe "forkes a particular project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user) }

    context "when not authenticated" do
      before do
        post "/api/v1/projects/#{project.id}/fork", as: :json
      end

      it "returns status :not_authorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & forks a non existent project" do
      before do
        token = get_auth_token(user)
        post "/api/v1/projects/0/fork",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when forks own project" do
      before do
        token = get_auth_token(user)
        post "/api/v1/projects/#{project.id}/fork",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :conflict" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when forks other user's project" do
      before do
        token = get_auth_token(random_user)
        post "/api/v1/projects/#{project.id}/fork",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :ok & return forked project" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project")
      end
    end

    context "when forks other user's project and includes author details" do
      before do
        token = get_auth_token(random_user)
        post "/api/v1/projects/#{project.id}/fork?include=author",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :ok & return forked project including author details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project_with_author")
      end
    end

    context "when forks other user's project and includes collaborators" do
      before do
        token = get_auth_token(random_user)
        post "/api/v1/projects/#{project.id}/fork?include=collaborators",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :ok & return forked project including collaborators" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("project_with_collaborators")
      end
    end
  end
end
