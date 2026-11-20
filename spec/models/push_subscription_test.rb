# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushSubscription, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    let(:user) { FactoryBot.create(:user) }
    let(:attrs) { { endpoint: "https://example.com/endpoint", p256dh: "p256dh_key", auth: "auth_key" } }

    before { described_class.create!(attrs.merge(user: user)) }

    it "rejects the same endpoint twice for one user" do
      expect(described_class.new(attrs.merge(user: user))).not_to be_valid
    end

    it "allows the same endpoint for a different user" do
      other_user = FactoryBot.create(:user)
      expect(described_class.new(attrs.merge(user: other_user))).to be_valid
    end
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

    context "when the push service reports the subscription is gone" do
      let(:user) { FactoryBot.create(:user) }
      let!(:saved_subscription) do
        described_class.create!(user: user, endpoint: "https://example.com/gone",
                                p256dh: "p256dh_key", auth: "auth_key")
      end

      [Webpush::ExpiredSubscription, Webpush::InvalidSubscription].each do |error_class|
        it "deletes the subscription on #{error_class}" do
          allow(Webpush).to receive(:payload_send)
            .and_raise(error_class.new(double(body: "gone"), "example.com"))

          expect { saved_subscription.send_push_notification("hi") }
            .to change(described_class, :count).by(-1)
        end
      end
    end
  end
end
