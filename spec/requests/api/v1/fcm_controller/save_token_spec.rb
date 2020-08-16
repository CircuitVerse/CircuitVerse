# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FcmController, "#save_token", type: :request do
  describe "create or update a user's token" do
    let(:user) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        post "/api/v1/fcm/token", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but token body is null" do
      before do
        token = get_auth_token(user)
        post "/api/v1/fcm/token",
             headers: { "Authorization": "Token #{token}" },
             params: { "token": nil }, as: :json
      end

      it "returns status unprocessable_identity" do
        expect(response).to have_http_status(422)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but token body is empty string" do
      before do
        token = get_auth_token(user)
        post "/api/v1/fcm/token",
             headers: { "Authorization": "Token #{token}" },
             params: { "token": "" }, as: :json
      end

      it "returns status unprocessable_identity" do
        expect(response).to have_http_status(422)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and user's token does not exists" do
      before do
        token = get_auth_token(user)
        post "/api/v1/fcm/token",
             headers: { "Authorization": "Token #{token}" },
             params: { "token": "token" }, as: :json

        # reloads user and associations
        user.reload
      end

      it "creates new token & returns 'token saved' message" do
        expect(response).to have_http_status(200)
        expect(response.parsed_body["message"]).to eq("token saved")
        expect(user.fcm.token).to eq("token")
      end
    end

    context "when authenticated and user's token already exists" do
      before do
        FactoryBot.create(:fcm, token: "token", user: user)

        token = get_auth_token(user)
        post "/api/v1/fcm/token",
             headers: { "Authorization": "Token #{token}" },
             params: { "token": "updated_token" }, as: :json

        # reloads user and associations
        user.reload
      end

      it "updates existing token & returns 'token saved' message" do
        expect(response).to have_http_status(200)
        expect(response.parsed_body["message"]).to eq("token saved")
        expect(user.fcm.token).to eq("updated_token")
      end
    end
  end
end
