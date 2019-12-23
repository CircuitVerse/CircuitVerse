# frozen_string_literal: true

class PushSubscription < ApplicationRecord
  belongs_to :user

  def send_push_notification(message, url = "")
    payload = {
        body: message,
        url: url
    }
    Webpush.payload_send(
        message: JSON.generate(payload),
        endpoint: self[:endpoint],
        p256dh: self[:p256dh],
        auth: self[:auth],
        vapid: {
            subject: "mailto:support@circuitverse.org",
            public_key: ENV["VAPID_PUBLIC_KEY"],
            private_key: ENV["VAPID_PRIVATE_KEY"]
        }
    )
  end
end
