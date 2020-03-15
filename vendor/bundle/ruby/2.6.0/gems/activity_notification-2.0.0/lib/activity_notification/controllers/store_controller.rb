module ActivityNotification
  class << self
    # Setter for remembering controller instance
    #
    # @param [NotificationsController, NotificationsWithDeviseController] controller Controller instance to set
    # @return [NotificationsController, NotificationsWithDeviseController]] Controller instance to be set
    def set_controller(controller)
      Thread.current[:activity_notification_controller] = controller
    end

    # Getter for accessing the controller instance
    #
    # @return [NotificationsController, NotificationsWithDeviseController]] Controller instance to be set
    def get_controller
      Thread.current[:activity_notification_controller]
    end
  end

  # Module included in controllers to allow ActivityNotification access to controller instance
  module StoreController
    extend ActiveSupport::Concern

    included do
      around_action :store_controller_for_activity_notification if     respond_to?(:around_action)
      around_filter :store_controller_for_activity_notification unless respond_to?(:around_action)
    end

    # Sets controller as around action to use controller instance in models or helpers
    def store_controller_for_activity_notification
      begin
        ActivityNotification.set_controller(self)
        yield
      ensure
        ActivityNotification.set_controller(nil)
      end
    end
  end
end
