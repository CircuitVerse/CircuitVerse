# frozen_string_literal: true

module CustomOptionalTarget
  # Custom optional target implementation for mobile push notification or SMS using Amazon SNS.
  class WebPush < ActivityNotification::OptionalTarget::Base
    # Initialize method to prepare Aws::SNS::Client
    def initialize_target(options = {})
    end

    # Publishes notification message to Amazon SNS
    def notify(notification, options = {})
      @user = notification.target
      message = notification.notifier.printable_notifier_name +
          " " + notification.notifiable.printable_notifiable_name(@user)
      @user.send_push_notification(message)
    end
  end
end
