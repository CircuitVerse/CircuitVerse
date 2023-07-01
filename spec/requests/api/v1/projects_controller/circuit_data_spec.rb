# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#circuit_data", type: :request do
  describe "get circuit data" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:private_project) { FactoryBot.create(:project, author: user) }
    let!(:public_project) do
      FactoryBot.create(:project, project_access_type: "Public", author: user)
    end

    context "when unauthenticated user fetches public project circuit data" do
      before do
        get "/api/v1/projects/#{public_project.id}/circuit_data", as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end

    context "when unauthenticated user fetches private project circuit data" do
      before do
        get "/api/v1/projects/#{private_project.id}/circuit_data", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user fetches his own public project circuit data" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{public_project.id}/circuit_data",
          headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end

    context "when authenticated user fetches his own private project circuit data" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{private_project.id}/circuit_data",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end

    context "when authenticated user fetches other user's public project circuit data" do
      before do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{public_project.id}/circuit_data",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end

    context "when authenticated user fetches other user's private project circuit data" do
      before do
        token = get_auth_token(random_user)
        get "/api/v1/projects/#{private_project.id}/circuit_data",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user fetches other users public project circuit data as collaborator" do
      before do
        token = get_auth_token(random_user)
        FactoryBot.create(:collaborator, project: public_project, user: random_user)
        get "/api/v1/projects/#{public_project.id}/circuit_data",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end

    context "when authenticated user fetches other users private project circuit data as collaborator" do
      before do
        token = get_auth_token(random_user)
        FactoryBot.create(:collaborator, project: private_project, user: random_user)
        get "/api/v1/projects/#{private_project.id}/circuit_data",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns circuit data" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("circuit_data")
      end
    end
  end
end
