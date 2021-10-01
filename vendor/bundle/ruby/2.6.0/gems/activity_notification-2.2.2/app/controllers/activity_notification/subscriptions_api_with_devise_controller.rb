module ActivityNotification
  # Controller to manage subscriptions API with Devise authentication.
  class SubscriptionsApiWithDeviseController < SubscriptionsApiController
    include DeviseTokenAuth::Concerns::SetUserByToken if defined?(DeviseTokenAuth)
    include DeviseAuthenticationController
  end
end