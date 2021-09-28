# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#unvote", type: :request do
  describe "unvote a comment" do
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:comment) do
      FactoryBot.create(
        :commontator_comment, creator: creator, thread: project.commontator_thread
      )
    end

    context "when not authenticated" do
      before do
        put "/api/v1/comments/#{comment.id}/unvote", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but don't have unvote access" do
      before do
        token = get_auth_token(creator)
        put "/api/v1/comments/#{comment.id}/unvote",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and & have upvote access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        put "/api/v1/comments/#{comment.id}/unvote",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status success & 'comment unvoted' message" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["message"]).to eq("comment unvoted")
      end
    end
  end
end
