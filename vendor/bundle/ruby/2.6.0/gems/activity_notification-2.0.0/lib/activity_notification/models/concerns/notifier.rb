module ActivityNotification
  # Notifier implementation included in notifier model to be notified, like users or administrators.
  module Notifier
    extend ActiveSupport::Concern

    included do
      include Common
      include Association

      # Has many sent notification instances from this notifier.
      # @scope instance
      # @return [Array<Notificaion>, Mongoid::Criteria<Notificaion>] Array or database query of sent notifications from this notifier
      has_many_records :sent_notifications,
        class_name: "::ActivityNotification::Notification",
        as: :notifier

      class_attribute :_printable_notifier_name
      set_notifier_class_defaults
    end

    class_methods do
      # Checks if the model includes notifier methods are available.
      # @return [Boolean] Always true
      def available_as_notifier?
        true
      end

      # Sets default values to notifier class fields.
      # @return [NilClass] nil
      def set_notifier_class_defaults
        self._printable_notifier_name = :printable_name
        nil
      end
    end

    # Returns printable notifier model name to show in view or email.
    # @return [String] Printable notifier model name
    def printable_notifier_name
      resolve_value(_printable_notifier_name)
    end
  end
end