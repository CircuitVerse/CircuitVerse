# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#index", type: :request do
  describe "get thread's comments" do
    let!(:private_project_author) { create(:user) }
    let!(:public_project) { create(:project, project_access_type: "Public") }
    let!(:private_project) { create(:project, author: private_project_author) }

    context "when not authenticated & public project's comments are fetched" do
      before do
        create_comments_for(public_project)
        get "/api/v1/threads/#{public_project.commontator_thread.id}/comments", as: :json
      end

      it "returns all comments" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("comments")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when not authenticated & private project's comments are fetched" do
      before do
        create_comments_for(private_project)
        get "/api/v1/threads/#{private_project.commontator_thread.id}/comments", as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & public project's comments are fetched" do
      before do
        create_comments_for(public_project)
        token = get_auth_token(create(:user))
        get "/api/v1/threads/#{public_project.commontator_thread.id}/comments",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all comments" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("comments")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authenticated but not as user whose private project's comments are fetched" do
      before do
        create_comments_for(private_project)
        token = get_auth_token(create(:user))
        get "/api/v1/threads/#{private_project.commontator_thread.id}/comments",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as user whose private project's comments are fetched" do
      before do
        create_comments_for(private_project)
        token = get_auth_token(private_project_author)
        get "/api/v1/threads/#{private_project.commontator_thread.id}/comments",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all comments" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("comments")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    def create_comments_for(project)
      create_list(
        :commontator_comment, 3,
        creator: create(:user),
        thread: project.commontator_thread
      )
    end
  end
end
