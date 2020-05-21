# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#user_projects", type: :request do
  describe "list user's projects" do
    let!(:user_one) { FactoryBot.create(:user) }
    let!(:user_two) { FactoryBot.create(:user) }
    let!(:public_project_user_one) { FactoryBot.create(
      :project, project_access_type: "Public", author: user_one, view: 1)
    }
    let!(:private_project_user_one) { FactoryBot.create(:project, author: user_one, view: 2) }
    let!(:public_project_user_two) { FactoryBot.create(
      :project, project_access_type: "Public", author: user_two, view: 3)
    }
    let!(:private_project_user_two) { FactoryBot.create(:project, author: user_two, view: 4) }

    context "when not authenticated" do
      before(:each) do
        get "/api/v1/users/#{user_one.id}/projects", as: :json
      end
      it "should return status 401" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated with user that fetches own projects" do
      before(:each) do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return user's all projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end

      it "should return user's private project" do
        expect(response.parsed_body["data"].any? {
          |proj| proj["id"].to_i == private_project_user_one.id
        }).to be(true)
      end

      it "should return user's public project" do
        expect(response.parsed_body["data"].any? {
          |proj| proj["id"].to_i == public_project_user_one.id
        }).to be(true)
      end
    end

    context "when authenticated and checks for projects sorted by views" do
      it "should return all user projects sorted by views in descending order" do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
        headers: { "Authorization": "Token #{token}" },
        params: { sort: "-view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([2, 1])
      end

      it "should return all user projects sorted by views in ascending order" do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/projects",
        headers: { "Authorization": "Token #{token}" },
        params: { sort: "view" }, as: :json
        views = response.parsed_body["data"].map { |proj| proj["attributes"]["view"] }
        expect(views).to eq([1, 2])
      end
    end

    context "when authenticated with user that fetches other user's projects" do
      before(:each) do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_two.id}/projects",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return other user's public only projects" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(1)
      end

      it "should not return other user's private project" do
        expect(response.parsed_body["data"].any? {
          |proj| proj["id"].to_i == private_project_user_two.id
        }).to be(false)
      end

      it "should return other user's public project" do
        expect(response.parsed_body["data"].any? {
          |proj| proj["id"].to_i == public_project_user_two.id
        }).to be(true)
      end
    end
  end
end
