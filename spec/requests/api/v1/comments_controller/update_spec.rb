# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#update", type: :request do
  describe "update a comment" do
    let!(:creator) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
    let!(:comment) do
      FactoryBot.create(
        :commontator_comment, creator: creator, thread: project.commontator_thread
      )
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/comments/#{comment.id}", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but don't have edit access" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        patch "/api/v1/comments/#{comment.id}",
              headers: { Authorization: "Token #{token}" }, as: :json
      end
      it "returns status forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & has edit access but invalid params" do
      before do
        token = get_auth_token(creator)
        patch "/api/v1/comments/#{comment.id}",
              headers: { Authorization: "Token #{token}" },
              params: { body: "" }, as: :json
      end

      it "returns status unprocessable_identity & can't be blank error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_error("Comment can't be blank")
      end
    end

    context "when authenticated & has edit access with valid params" do
      before do
        token = get_auth_token(creator)
        patch "/api/v1/comments/#{comment.id}",
              headers: { Authorization: "Token #{token}" },
              params: { body: "updated_body" }, as: :json
      end

      it "returns status accepted & edited comment" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("comment")
        expect(response.parsed_body["data"]["attributes"]["body"]).to eq("updated_body")
      end
    end
  end
end
