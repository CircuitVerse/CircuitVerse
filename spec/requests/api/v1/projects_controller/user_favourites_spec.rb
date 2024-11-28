# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#user_favourites", type: :request do
  describe "list all starred projects" do
    let!(:user_one) { create(:user) }
    let!(:user_two) { create(:user) }

    before do
      create(
        :star, user: user_one, project: create(
          :project, author: user_one
        )
      )
      create(
        :star, user: user_one, project: create(
          :project, project_access_type: "Public", author: user_one
        )
      )
      create(
        :star, user: user_one, project: create(
          :project, project_access_type: "Public", author: user_two
        )
      )
    end

    context "when not authenticated and fetches some user's favourites" do
      before do
        get "/api/v1/users/#{user_one.id}/favourites", as: :json
      end

      it "returns all public projects starred by user" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end

    context "when authenticated as the user whose favourites are not being fetched" do
      before do
        token = get_auth_token(user_two)
        get "/api/v1/users/#{user_one.id}/favourites",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all public projects starred by user" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(2)
      end
    end

    context "when authenticated as the user whose favourites are being fetched" do
      before do
        token = get_auth_token(user_one)
        get "/api/v1/users/#{user_one.id}/favourites",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all projects including privates starred by user" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("projects")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end
  end
end
