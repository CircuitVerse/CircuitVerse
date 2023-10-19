# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#undelete" do
  describe "undelete a comment" do
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:comment) do
      FactoryBot.create(
        :commontator_comment, creator: creator, thread: project.commontator_thread
      )
    end

    context "when not authenticated" do
      before do
        put "/api/v1/comments/#{comment.id}/undelete", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but don't have undelete access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        put "/api/v1/comments/#{comment.id}/undelete",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & has undelete access but comment is not already deleted" do
      before do
        token = get_auth_token(creator)
        put "/api/v1/comments/#{comment.id}/undelete",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found & 'comment does not exists' error" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_error("comment does not exists")
      end
    end

    context "when authenticated & has undelete access" do
      before do
        comment.delete_by(creator)
        token = get_auth_token(creator)
        put "/api/v1/comments/#{comment.id}/undelete",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status success & undeleted comment" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("comment")
      end
    end
  end
end
