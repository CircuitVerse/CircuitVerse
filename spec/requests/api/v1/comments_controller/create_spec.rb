# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CommentsController, "#create", type: :request do
  describe "create a comment" do
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    context "when not authenticated" do
      before do
        post "/api/v1/threads/#{project.commontator_thread.id}/comments", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but thread is closed" do
      before do
        project.commontator_thread.close(FactoryBot.create(:user))

        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/threads/#{project.commontator_thread.id}/comments",
             headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status forbidden" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated with thread opened but empty body" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/threads/#{project.commontator_thread.id}/comments",
             headers: { "Authorization": "Token #{token}" },
             params: { "body": "" }, as: :json
      end

      it "returns status unprocessable_identity & can't be blank error" do
        expect(response).to have_http_status(422)
        expect(response.parsed_body).to have_jsonapi_error("Comment can't be blank")
      end
    end

    context "when authenticated with thread open & valid params" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/threads/#{project.commontator_thread.id}/comments",
             headers: { "Authorization": "Token #{token}" },
             params: { "body": "new_comment" }, as: :json
      end

      it "returns status created & created comment" do
        expect(response).to have_http_status(201)
        expect(response).to match_response_schema("comment")
      end
    end
  end
end
