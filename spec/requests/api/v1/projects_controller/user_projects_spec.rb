# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#user_projects", type: :request do
  describe "list user's projects" do
    let!(:user_one) { FactoryBot.create(:user) }
    let!(:user_two) { FactoryBot.create(:user) }
    let!(:public_project_user_one) do
      FactoryBot.create(:project, project_access_type: "Public", author: user_one, view: 1)
    end
    let!(:private_project_user_one) { FactoryBot.create(:project, author: user_one, view: 2) }
    let!(:public_project_user_two) do
      FactoryBot.create(:project, project_access_type: "Public", author: user_two, view: 3)
    end
    let!(:private_project_user_two) { FactoryBot.create(:project, author: user_two, view: 4) }

    context "when not authenticated" do
      before do
        get "/api/v1/users/#{user_one.id}/projects", as: :json
      end

      it "returns status 401" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated with user that fetches own projects" do
      before do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns user's all projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end

      it "returns user's private project" do
        expect(response.parsed_body["data"].any? do |proj|
          proj["id"].to_i == private_project_user_one.id
        end).to be(true)
      end

      it "returns user's public project" do
        expect(response.parsed_body["data"].any? do |proj|
          proj["id"].to_i == public_project_user_one.id
        end).to be(true)
      end
    end

    context "when authenticated and checks for projects sorted in :ASC by views" do
      before do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "view" }, as: :json
      end

      it "returns all projects sorted by views in ascending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([1, 2])
      end
    end

    context "when authenticated and checks for projects sorted in :DESC by views" do
      before do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
            headers: { "Authorization": "Token #{token}" },
            params: { sort: "-view" }, as: :json
      end

      it "returns all projects sorted by views in descending order" do
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([2, 1])
      end
    end

    context "when authenticated with user that fetches other user's projects" do
      before do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_two.id}/projects",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns other user's public only projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(1)
      end

      it "does not return other user's private project" do
        expect(response.parsed_body["data"].any? do |proj|
          proj["id"].to_i == private_project_user_two.id
        end).to be(false)
      end

      it "returns other user's public project" do
        expect(response.parsed_body["data"].any? do |proj|
          proj["id"].to_i == public_project_user_two.id
        end).to be(true)
      end
    end
  end
end
