module ActivityNotification
  # Notification group implementation included in group model to bundle notification.
  module Group
    extend ActiveSupport::Concern
    included do
      include Common
      class_attribute :_printable_notification_group_name
      set_group_class_defaults
    end

    class_methods do
      # Checks if the model includes notification group methods are available.
      # @return [Boolean] Always true
      def available_as_group?
        true
      end

      # Sets default values to group class fields.
      # @return [NilClass] nil
      def set_group_class_defaults
        self._printable_notification_group_name = :printable_name
        nil
      end
    end

    # Returns printable group model name to show in view or email.
    # @return [String] Printable group model name
    def printable_group_name
      resolve_value(_printable_notification_group_name)
    end
  end
end