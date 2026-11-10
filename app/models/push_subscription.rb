# frozen_string_literal: true

class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: { scope: :user_id }

  def send_push_notification(message, url = "")
    Webpush.payload_send(
      message: JSON.generate({ body: message, url: url }),
      endpoint: self[:endpoint],
      p256dh: self[:p256dh],
      auth: self[:auth],
      vapid: vapid_options
    )
  rescue Webpush::ExpiredSubscription, Webpush::InvalidSubscription
    destroy
    nil
  end

  private

    def vapid_options
      {
        subject: "mailto:support@circuitverse.org",
        public_key: Rails.application.config.vapid_public_key,
        private_key: Rails.application.config.vapid_private_key
      }
    end
end
