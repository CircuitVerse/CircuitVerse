# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#signup", type: :request do
  describe "user sign up" do
    let!(:user) { FactoryBot.build(:user) }

    context "with missing params" do
      before(:each) do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email
        }
      end
      it "return status 422 and should have jsonapi errors" do
        expect(response).to have_http_status(422)
        expect(response.body).to have_jsonapi_errors()
      end
    end

    context "with invalid params" do
      before(:each) do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email, password: "1"
        }
      end
      it "return status 422 and should have jsonapi errors" do
        expect(response).to have_http_status(422)
        expect(response.body).to have_jsonapi_errors()
      end
    end

    context "user already exists" do
      before(:each) do
        existing_user = FactoryBot.create(:user)
        post "/api/v1/auth/signup", params: {
          name: existing_user.name, email: existing_user.email, password: "1"
        }
      end
      it "return status 409 and should have jsonapi errors" do
        expect(response).to have_http_status(409)
        expect(response.body).to have_jsonapi_errors()
      end
    end

    context "with valid params" do
      before(:each) do
        post "/api/v1/auth/signup", params: {
          name: user.name, email: user.email, password: user.password
        }
      end
      it "return status 201 and respond with token" do
        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)).to have_key("token")
      end
    end
  end
end
