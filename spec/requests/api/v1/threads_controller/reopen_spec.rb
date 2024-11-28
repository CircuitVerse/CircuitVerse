# frozen_string_literal: true

RSpec.describe Api::V1::ThreadsController, "#reopen", type: :request do
  describe "reopen a thread" do
    let!(:user) { create(:user) }
    let!(:project) { create(:project, project_access_type: "Public") }

    context "when not authenticated" do
      before do
        put "/api/v1/threads/#{project.commontator_thread.id}/reopen", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but thread is already opened" do
      before do
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/reopen",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict & 'thread is already opened' error" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_error("thread is already opened")
      end
    end

    context "when authenticated & thread is closed" do
      before do
        project.commontator_thread.close(user)
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/reopen",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status success & 'thread reopened' message" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["message"]).to eq("thread reopened")
      end
    end
  end
end
