module ActivityNotification
  # Controller to manage notifications API with Devise authentication.
  class NotificationsApiWithDeviseController < NotificationsApiController
    include DeviseTokenAuth::Concerns::SetUserByToken if defined?(DeviseTokenAuth)
    include DeviseAuthenticationController
  end
end