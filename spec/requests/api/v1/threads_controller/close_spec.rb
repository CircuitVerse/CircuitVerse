# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ThreadsController, "#close", type: :request do
  describe "close a thread" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    context "when not authenticated" do
      before do
        put "/api/v1/threads/#{project.commontator_thread.id}/close", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but thread is already closed" do
      before do
        project.commontator_thread.close(user)
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/close",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict & 'thread is already closed' error" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_error("thread is already closed")
      end
    end

    context "when authenticated & thread is not already closed" do
      before do
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/close",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status success & 'thread closed' message" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["message"]).to eq("thread closed")
      end
    end
  end
end
