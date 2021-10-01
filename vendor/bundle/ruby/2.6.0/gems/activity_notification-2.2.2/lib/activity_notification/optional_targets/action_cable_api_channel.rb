module ActivityNotification
  module OptionalTarget
    # Optional target implementation to broadcast to Action Cable API channel
    class ActionCableApiChannel < ActivityNotification::OptionalTarget::Base
      # Initialize method to prepare Action Cable API channel
      # @param [Hash] options Options for initializing
      # @option options [String] :channel_prefix          (ActivityNotification.config.notification_api_channel_prefix) Channel name prefix to broadcast notifications
      # @option options [String] :composite_key_delimiter (ActivityNotification.config.composite_key_delimiter)         Composite key delimiter for channel name
      def initialize_target(options = {})
        @channel_prefix = options.delete(:channel_prefix) || ActivityNotification.config.notification_api_channel_prefix
        @composite_key_delimiter = options.delete(:composite_key_delimiter) || ActivityNotification.config.composite_key_delimiter
      end

      # Broadcast to ActionCable API subscribers
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      def notify(notification, options = {})
        if notification_action_cable_api_allowed?(notification)
          target_channel_name = "#{@channel_prefix}_#{notification.target_type}#{@composite_key_delimiter}#{notification.target_id}"
          ActionCable.server.broadcast(target_channel_name, format_message(notification, options))
        end
      end

      # Check if Action Cable notification API is allowed
      # @param [Notification] notification Notification instance
      # @return [Boolean] Whether Action Cable notification API is allowed
      def notification_action_cable_api_allowed?(notification)
        notification.target.notification_action_cable_allowed?(notification.notifiable, notification.key) &&
          notification.notifiable.notifiable_action_cable_api_allowed?(notification.target, notification.key)
      end

      # Format message to broadcast
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      # @return [Hash] Formatted message to broadcast
      def format_message(notification, options = {})
        {
          notification: notification.as_json(notification_json_options.merge(options)),
          group_owner:  notification.group_owner? ? nil : notification.group_owner.as_json(notification_json_options.merge(options))
        }
      end

      protected

        # Returns options for notification JSON
        # @api protected
        def notification_json_options
          {
            include: {
              target: { methods: [:printable_type, :printable_target_name] },
              notifiable: { methods: [:printable_type] },
              group: { methods: [:printable_type, :printable_group_name] },
              notifier: { methods: [:printable_type, :printable_notifier_name] },
              group_members: {}
            },
            methods: [:notifiable_path, :printable_notifiable_name, :group_member_notifier_count, :group_notification_count, :text]
          }
        end

        # Overriden rendering notification message using format_message
        # @param [Notification] notification Notification instance
        # @param [Hash]         options      Options for rendering
        # @return [String] Rendered json formatted message to broadcast
        def render_notification_message(notification, options = {})
          format_message(notification, options)
        end
    end
  end
end