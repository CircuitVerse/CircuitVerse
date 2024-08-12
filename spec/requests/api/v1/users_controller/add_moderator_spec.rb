# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController,'#add_moderators' type: :request do
  before do
    @admin_user = FactoryBot.create(:user, admin: true)
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  context "when question bank feature is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
    end

    context "as an admin" do
      before do
        sign_in @admin_user
      end

      it "returns forbidden error when trying to add moderators" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end

      it "returns forbidden error when emails are invalid" do
        post "/api/v1/users/add_moderators", params: { emails: "invalid_email" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end

      it "returns forbidden error when no emails are provided" do
        post "/api/v1/users/add_moderators", params: { emails: "" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end
    end

    context "as a normal user" do
      before do
        sign_in @user
      end

      it "returns forbidden error when trying to add moderators" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end
    end
  end
end
