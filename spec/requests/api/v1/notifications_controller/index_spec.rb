# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NotificationsController, "#index" do
  describe "list all notifications" do
    context "when not authenticated" do
      before do
        get "/api/v1/notifications", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated" do
      before do
        @author = FactoryBot.create(:user)
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, author: @author)
        @notification = FactoryBot.create(
          :noticed_notification,
          recipient: @author,
          params:
            { user: @user, project: @project },
          read_at: nil
        )
      end

      it "list the notifications" do
        token = get_auth_token(@author)
        get "/api/v1/notifications",
            headers: { Authorization: "Token #{token}" }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("unread_notifications")
        expect(response.parsed_body["data"].length).to eq(1)
      end
    end
  end
end
