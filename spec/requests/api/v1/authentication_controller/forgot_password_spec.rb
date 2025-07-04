# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, "#forgot_password", type: :request do
  describe "forgot password" do
    context "when user who forgot his/her password does not exists" do
      before do
        post "/api/v1/password/forgot", params: { email: "test@test.com" }, as: :json
      end

      it "returns status 404 and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when user who forgot his/her password exists" do
      let!(:user) { FactoryBot.create(:user) }

      it "returns status 200 and should send reset password instructions" do
        perform_enqueued_jobs do
          expect do
            post "/api/v1/password/forgot", params: { email: user.email }, as: :json
          end.to change { ActionMailer::Base.deliveries.count }.by(1)

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
