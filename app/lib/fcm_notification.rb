# frozen_string_literal: true

class FcmNotification
  def self.send(registration_tokens, title, body, data = {})
    fcm = FCM.new(ENV["FCM_SERVER_KEY"])
    options = {
      "notification": {
        "title": title,
        "body": body
      },
      "data": data
    }

    fcm.send(registration_tokens, options)
  end
end
