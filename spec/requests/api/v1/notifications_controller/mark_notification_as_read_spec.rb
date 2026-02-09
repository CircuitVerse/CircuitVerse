# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NotificationsController, "#mark_as_read", type: :request do
  describe "mark notification as read" do
    context "when not authenticated" do
      before do
        get "/api/v1/notifications", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as notification owner" do
      before do
        @owner = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, author: @owner)
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @owner,
          params: { user: @other_user, project: @project },
          read_at: nil
        )
      end

      it "marks notification as read" do
        token = get_auth_token(@owner)
        patch "/api/v1/notifications/mark_as_read/#{@notification.id}",
              headers: { Authorization: "Token #{token}" }, as: :json
        expect(response).to have_http_status(:created)
        expect(response).to match_response_schema("read_notification")
      end
    end

    context "when another user tries to mark notification (IDOR protection)" do
      before do
        @owner = FactoryBot.create(:user)
        @attacker = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, author: @owner)
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @owner,
          params: { user: @attacker, project: @project },
          read_at: nil
        )
      end

      it "returns 404 not found and does not mark notification as read" do
        token = get_auth_token(@attacker)
        expect do
          patch "/api/v1/notifications/mark_as_read/#{@notification.id}",
                headers: { Authorization: "Token #{token}" }, as: :json
        end.not_to change { @notification.reload.read_at }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
