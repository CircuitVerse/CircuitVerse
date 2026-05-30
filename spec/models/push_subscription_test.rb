# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushSubscription, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "#send_push_notification" do
    let(:push_subscription) do
      described_class.new(
        endpoint: "https://example.com/endpoint",
        p256dh: "p256dh_key",
        auth: "auth_key"
      )
    end

    it "sends a push notification with the provided message and URL" do
      message = "Hello, world!"
      url = "https://example.com"

      payload = {
        body: message,
        url: url
      }

      vapid_config = {
        subject: "mailto:support@circuitverse.org",
        public_key: Rails.application.config.vapid_public_key,
        private_key: Rails.application.config.vapid_private_key
      }

      expect(Webpush).to receive(:payload_send).with(
        message: JSON.generate(payload),
        endpoint: push_subscription.endpoint,
        p256dh: push_subscription.p256dh,
        auth: push_subscription.auth,
        vapid: vapid_config
      )

      push_subscription.send_push_notification(message, url)
    end
  end
end
