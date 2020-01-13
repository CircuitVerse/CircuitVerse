# frozen_string_literal: true
# https://github.com/nanoc/nanoc/commit/f41a25626df915415c720f1c6278fe5b7a51ba10
loader = Zeitwerk::Loader.new
loader.push_dir(__dir__ + '/..')
loader.ignore(__dir__ + '/..')
loader.setup
loader.eager_load
  
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
