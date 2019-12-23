# frozen_string_literal: true

require "rails_helper"

describe Users::NotificationsController, type: :request do
  it "should get index page" do
    get root_path
    expect(response.status).to eq(200)
  end

  describe "Authentication" do
    before do
      @user1 = FactoryBot.create(:user)
      @user2 = FactoryBot.create(:user)
    end

    context "User is not authorized" do
      it "does not allow user to access notifications" do
        sign_in @user1
        get "/users/#{@user2.id}/notifications"
        expect(response.body).to eq("Not Authorized: Wrong user")
      end
    end
  end
end
