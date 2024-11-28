# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CollaboratorsController, "#index", type: :request do
  describe "list all collaborators" do
    let!(:author) { create(:user) }
    let!(:public_project) do
      create(:project, author: author, project_access_type: "Public")
    end
    let!(:private_project) { create(:project, author: author) }

    context "when not authenticated" do
      before do
        get "/api/v1/projects/#{public_project.id}/collaborators/", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but invalid/non-existent project" do
      before do
        token = get_auth_token(create(:user))
        get "/api/v1/projects/0/collaborators/",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized to fetch project's collaborators which user has view access to" do
      before do
        # create 3 collaborators for a public project
        create_list(:user, 3).each do |u|
          create(:collaboration, user: u, project: public_project)
        end
        token = get_auth_token(create(:user))
        get "/api/v1/projects/#{public_project.id}/collaborators/",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all the collaborators for the given project" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("users")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when fetching project's collaborators which user doesn't have view access to" do
      before do
        # create 3 collaborators for a private project
        create_list(:user, 3).each do |u|
          create(:collaboration, user: u, project: private_project)
        end
        token = get_auth_token(create(:user))
        get "/api/v1/projects/#{private_project.id}/collaborators/",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end
  end
end
