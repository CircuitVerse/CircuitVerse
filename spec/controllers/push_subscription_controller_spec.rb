# frozen_string_literal: true

require "rails_helper"

describe PushSubscriptionController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  describe "#create" do
    it "creates a push subscription" do
      post "/push/subscription/new", params: { push_subscription: {
          # Fake endpoint, for tests only
          endpoint: "https://fcm.googleapis.com/fcm/send/",
          auth: "GVWfxR22Bomw-uqi32NeBQ",
          # Fake ecdh public key
          p256dh: "BIdTz6j5RQ6Hf3QnFnpg3eYzro"
      } }
      expect(response.status).to eq(201)
      expect(@user.push_subscriptions.length).to eq(1)
      subscription = @user.push_subscriptions.first
      expect(subscription).to_not be_nil
    end
  end
end
