module ActivityNotification
  module OptionalTarget
    # Optional target implementation to broadcast to Action Cable channel
    class ActionCableChannel < ActivityNotification::OptionalTarget::Base
      # Initialize method to prepare Action Cable channel
      # @param [Hash] options Options for initializing
      # @option options [String] :channel_prefix          (ActivityNotification.config.notification_channel_prefix) Channel name prefix to broadcast notifications
      # @option options [String] :composite_key_delimiter (ActivityNotification.config.composite_key_delimiter)     Composite key delimiter for channel name
      def initialize_target(options = {})
        @channel_prefix          = options.delete(:channel_prefix)          || ActivityNotification.config.notification_channel_prefix
        @composite_key_delimiter = options.delete(:composite_key_delimiter) || ActivityNotification.config.composite_key_delimiter
      end

      # Broadcast to ActionCable subscribers
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      # @option options [String, Symbol] :target                 (nil)                     Target type name to find template or i18n text
      # @option options [String]         :partial_root           ("activity_notification/notifications/#{target}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name
      # @option options [String]         :partial                (self.key.tr('.', '/'))   Root path of partial template
      # @option options [String]         :layout                 (nil)                     Layout template name
      # @option options [String]         :layout_root            ('layouts')               Root path of layout template
      # @option options [String, Symbol] :fallback               (:default)                Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
      # @option options [String]         :filter                 (nil)                     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
      # @option options [String]         :limit                  (nil)                     Limit to query for notifications
      # @option options [String]         :without_grouping       ('false')                 If notification index will include group members
      # @option options [String]         :with_group_members     ('false')                 If notification index will include group members
      # @option options [String]         :filtered_by_type       (nil)                     Notifiable type for filter
      # @option options [String]         :filtered_by_group_type (nil)                     Group type for filter, valid with :filtered_by_group_id
      # @option options [String]         :filtered_by_group_id   (nil)                     Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]         :filtered_by_key        (nil)                     Key of the notification for filter
      # @option options [String]         :later_than             (nil)                     ISO 8601 format time to filter notification index later than specified time
      # @option options [String]         :earlier_than           (nil)                     ISO 8601 format time to filter notification index earlier than specified time
      # @option options [Hash]           others                                            Parameters to be set as locals
      def notify(notification, options = {})
        if notification_action_cable_allowed?(notification)
          target_channel_name = "#{@channel_prefix}_#{notification.target_type}#{@composite_key_delimiter}#{notification.target_id}"
          index_options = options.slice(:filter, :limit, :without_grouping, :with_group_members, :filtered_by_type, :filtered_by_group_type, :filtered_by_group_id, :filtered_by_key, :later_than, :earlier_than)
          ActionCable.server.broadcast(target_channel_name, format_message(notification, options))
        end
      end

      # Check if Action Cable notification is allowed
      # @param [Notification] notification Notification instance
      # @return [Boolean] Whether Action Cable notification is allowed
      def notification_action_cable_allowed?(notification)
        notification.target.notification_action_cable_allowed?(notification.notifiable, notification.key) &&
          notification.notifiable.notifiable_action_cable_allowed?(notification.target, notification.key)
      end

      # Format message to broadcast
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      # @return [Hash] Formatted message to broadcast
      def format_message(notification, options = {})
        index_options = options.slice(:filter, :limit, :without_grouping, :with_group_members, :filtered_by_type, :filtered_by_group_type, :filtered_by_group_id, :filtered_by_key, :later_than, :earlier_than)
        {
          id:                          notification.id,
          view:                        render_notification_message(notification, options),
          text:                        notification.text(options),
          notifiable_path:             notification.notifiable_path,
          group_owner_id:              notification.group_owner_id,
          group_owner_view:            notification.group_owner? ? nil : render_notification_message(notification.group_owner, options),
          unopened_notification_count: notification.target.unopened_notification_count(index_options)
        }
      end
    end
  end
end