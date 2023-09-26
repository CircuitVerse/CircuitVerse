# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#signup" do
  describe "user sign up" do
    let!(:user) { FactoryBot.build(:user) }

    context "with missing params" do
      before do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email
        }, as: :json
      end

      it "return status 422 and should have jsonapi errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with invalid params" do
      before do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email, password: "1"
        }, as: :json
      end

      it "return status 422 and should have jsonapi errors" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when user already exists" do
      before do
        existing_user = FactoryBot.create(:user)
        post "/api/v1/auth/signup", params: {
          name: existing_user.name, email: existing_user.email, password: "1"
        }, as: :json
      end

      it "return status 409 and should have jsonapi errors" do
        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "with valid params" do
      before do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email, password: user.password
        }, as: :json
      end

      it "return status 201 and respond with token" do
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to have_key("token")
      end
    end
  end
end
