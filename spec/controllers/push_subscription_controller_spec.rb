# frozen_string_literal: true

require "rails_helper"

describe PushSubscriptionController do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  describe "#create" do
    it "creates a push subscription" do
      post "/push/subscription/new", params: { push_subscription: {
        endpoint: "Dummy",
        auth: "Dummy",
        p256dh: "Dummy"
      } }
      expect(response).to have_http_status(:created)
      expect(@user.push_subscriptions.length).to eq(1)
      subscription = @user.push_subscriptions.first
      expect(subscription).not_to be_nil
    end
  end
end
