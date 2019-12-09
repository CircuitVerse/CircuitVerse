# frozen_string_literal: true

module CustomOptionalTarget
  class WebPush < ActivityNotification::OptionalTarget::Base
    def initialize_target(options = {})
    end

    def notify(notification, options = {})
      @user = notification.target
      message = notification.notifier.printable_notifier_name +
          " " + notification.notifiable.printable_notifiable_name(@user)
      @user.send_push_notification(message, notification.notifiable.
          notifiable_path(User, notification.key))
    end
  end
end
