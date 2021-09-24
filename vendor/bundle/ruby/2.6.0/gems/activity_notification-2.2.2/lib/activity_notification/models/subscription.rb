module ActivityNotification
  # Subscription model implementation with ORM.
  class Subscription < inherit_orm("Subscription")
    include Swagger::SubscriptionSchema
  end
end

