module ActivityNotification
  # Notification model implementation with ORM.
  class Notification < inherit_orm("Notification")
    include Swagger::NotificationSchema
  end
end
