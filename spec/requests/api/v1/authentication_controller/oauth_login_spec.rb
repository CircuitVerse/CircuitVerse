# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#oauth_login", type: :request do
  describe "oauth user login" do
    let!(:user) { FactoryBot.create(:user) }

    context "when user does not already exists" do
      before do
        new_user = FactoryBot.build(:user)
        post "/api/v1/oauth/login", params: { email: new_user.email }, as: :json
      end

      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with valid params" do
      before do
        post "/api/v1/oauth/login", params: { email: user.email }, as: :json
      end

      it "return status 202 and respond with token" do
        expect(response).to have_http_status(202)
        expect(response.parsed_body).to have_key("token")
      end
    end
  end
end
