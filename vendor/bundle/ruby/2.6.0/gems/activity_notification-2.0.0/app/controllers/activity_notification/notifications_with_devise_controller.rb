module ActivityNotification
  # Controller to manage notifications with Devise authentication.
  class NotificationsWithDeviseController < NotificationsController
    include DeviseAuthenticationController
  end
end
