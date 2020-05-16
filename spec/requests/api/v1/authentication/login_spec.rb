# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#login", type: :request do
  describe "user login" do
    let!(:user) { FactoryBot.create(:user) }

    context "with invalid password" do
      before(:each) do
        post "/api/v1/auth/login", params: {
          email: user.email, password: "invalid"
        }
      end
      it "return status 401 and should have jsonapi errors" do
        expect(response).to have_http_status(401)
        expect(response.body).to have_jsonapi_errors()
      end
    end

    context "user does not already exists" do
      before(:each) do
        new_user = FactoryBot.build(:user)
        post "/api/v1/auth/login", params: {
          email: new_user.email, password: new_user.password
        }
      end
      it "return status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(404)
        expect(response.body).to have_jsonapi_errors()
      end
    end

    context "with valid params" do
      before(:each) do
        post "/api/v1/auth/login", params: {
          email: user.email, password: user.password
        }
      end
      it "return status 202 and respond with token" do
        expect(response).to have_http_status(202)
        expect(JSON.parse(response.body)).to have_key("token")
      end
    end
  end
end
