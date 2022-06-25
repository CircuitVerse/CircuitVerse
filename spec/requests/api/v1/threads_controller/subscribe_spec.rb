# frozen_string_literal: true

RSpec.describe Api::V1::ThreadsController, "#subscribe", type: :request do
  describe "subscribe a thread" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    context "when not authenticated" do
      before do
        put "/api/v1/threads/#{project.commontator_thread.id}/subscribe", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but thread is already subscribed" do
      before do
        project.commontator_thread.subscribe(user)
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/subscribe",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status conflict & 'thread already subscribed' error" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_error("thread already subscribed")
      end
    end

    context "when authenticated & thread is not already subscribed" do
      before do
        token = get_auth_token(user)
        put "/api/v1/threads/#{project.commontator_thread.id}/subscribe",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status success & 'thread subscribed' message" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["message"]).to eq("thread subscribed")
      end
    end
  end
end
