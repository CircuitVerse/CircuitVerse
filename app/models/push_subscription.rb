# frozen_string_literal: true

#
# == Schema Information
#
# Table name: push_subscriptions
#
#  id         :bigint           not null, primary key
#  endpoint   :string
#  p256dh     :string
#  auth       :string
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_push_subscriptions_on_user_id  (user_id)
#

class PushSubscription < ApplicationRecord
  belongs_to :user

  # @param [String] message
  # @param [String] url
  # @return [Net::HTTPRequest] Returns a Net::HTTPRequest object
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
        public_key: Rails.application.config.vapid_public_key,
        private_key: Rails.application.config.vapid_private_key
      }
    )
  end
end
