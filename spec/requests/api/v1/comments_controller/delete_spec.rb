# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#delete", type: :request do
  describe "delete a comment" do
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:comment) do
      FactoryBot.create(
        :commontator_comment, creator: creator, thread: project.commontator_thread
      )
    end

    context "when not authenticated" do
      before do
        put "/api/v1/comments/#{comment.id}/delete", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but don't have delete access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        put "/api/v1/comments/#{comment.id}/delete",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & has delete access but comment is already deleted" do
      before do
        comment.delete_by(creator)
        token = get_auth_token(creator)
        put "/api/v1/comments/#{comment.id}/delete",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict & 'already deleted' error" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_error("already deleted")
      end
    end

    context "when authenticated & has delete access" do
      before do
        token = get_auth_token(creator)
        put "/api/v1/comments/#{comment.id}/delete",
            headers: { Authorization: "Token #{token}" }, as: :json

        # reload comment to update comment params after being deleted
        comment.reload
      end

      it "deletes comment & returns status no_content" do
        expect(response).to have_http_status(:no_content)
        expect(comment.is_deleted?).to be true
      end
    end
  end
end
