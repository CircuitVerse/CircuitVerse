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
        endpoint: "Dummy",
        auth: "Dummy",
        p256dh: "Dummy"
      } }
      expect(response.status).to eq(201)
      expect(@user.push_subscriptions.length).to eq(1)
      subscription = @user.push_subscriptions.first
      expect(subscription).not_to be_nil
    end

    it "does not create a duplicate when the same endpoint is posted twice" do
      params = { push_subscription: { endpoint: "https://example.com/e", auth: "auth", p256dh: "p256dh" } }

      post "/push/subscription/new", params: params
      post "/push/subscription/new", params: params

      expect(response.status).to eq(201)
      expect(@user.push_subscriptions.count).to eq(1)
    end

    it "updates the keys when the same endpoint is posted again" do
      endpoint = "https://example.com/e"
      post "/push/subscription/new", params: { push_subscription: { endpoint: endpoint, auth: "old", p256dh: "old" } }
      post "/push/subscription/new", params: { push_subscription: { endpoint: endpoint, auth: "new", p256dh: "new" } }

      subscription = @user.push_subscriptions.find_by(endpoint: endpoint)
      expect(@user.push_subscriptions.count).to eq(1)
      expect(subscription.auth).to eq("new")
      expect(subscription.p256dh).to eq("new")
    end
  end

  describe "#test" do
    it "sends the message to each of the user's subscriptions" do
      @user.push_subscriptions.create!(endpoint: "https://example.com/a", auth: "auth", p256dh: "p256dh")
      allow(Webpush).to receive(:payload_send)

      post "/push/test", params: { push: { message: "hello" } }

      expect(response.status).to eq(204)
      expect(Webpush).to have_received(:payload_send).with(hash_including(endpoint: "https://example.com/a"))
    end
  end
end
