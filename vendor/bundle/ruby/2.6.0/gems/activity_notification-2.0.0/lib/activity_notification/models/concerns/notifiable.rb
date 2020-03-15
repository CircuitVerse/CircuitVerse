module ActivityNotification
  # Notifiable implementation included in notifiable model to be notified, like comments or any other user activities.
  module Notifiable
    extend ActiveSupport::Concern
    # include PolymorphicHelpers to resolve string extentions
    include ActivityNotification::PolymorphicHelpers

    included do
      include Common
      include Association
      include ActionDispatch::Routing::PolymorphicRoutes
      include Rails.application.routes.url_helpers

      # Has many notification instances for this notifiable.
      # Dependency for these notifications can be overridden from acts_as_notifiable.
      # @scope instance
      # @return [Array<Notificaion>, Mongoid::Criteria<Notificaion>] Array or database query of notifications for this notifiable
      has_many_records :generated_notifications_as_notifiable,
        class_name: "::ActivityNotification::Notification",
        as: :notifiable

      class_attribute :_notification_targets,
                      :_notification_group,
                      :_notification_group_expiry_delay,
                      :_notifier,
                      :_notification_parameters,
                      :_notification_email_allowed,
                      :_notification_action_cable_allowed,
                      :_notifiable_path,
                      :_printable_notifiable_name,
                      :_optional_targets
      set_notifiable_class_defaults
    end

    # Returns default_url_options for polymorphic_path.
    # @return [Hash] Rails.application.routes.default_url_options
    def default_url_options
      Rails.application.routes.default_url_options
    end

    class_methods do
      # Checks if the model includes notifiable and notifiable methods are available.
      # @return [Boolean] Always true
      def available_as_notifiable?
        true
      end

      # Sets default values to notifiable class fields.
      # @return [NilClass] nil
      def set_notifiable_class_defaults
        self._notification_targets              = {}
        self._notification_group                = {}
        self._notification_group_expiry_delay   = {}
        self._notifier                          = {}
        self._notification_parameters           = {}
        self._notification_email_allowed        = {}
        self._notification_action_cable_allowed = {}
        self._notifiable_path                   = {}
        self._printable_notifiable_name         = {}
        self._optional_targets                  = {}
        nil
      end
    end

    # Returns notification targets from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @return [Array<Notificaion> | ActiveRecord_AssociationRelation<Notificaion>] Array or database query of the notification targets
    def notification_targets(target_type, options = {})
      target_typed_method_name = "notification_#{cast_to_resources_name(target_type)}"
      resolved_parameter = resolve_parameter(
        target_typed_method_name,
        _notification_targets[cast_to_resources_sym(target_type)],
        nil,
        options)
      unless resolved_parameter
        raise NotImplementedError, "You have to implement #{self.class}##{target_typed_method_name} "\
                                   "or set :targets in acts_as_notifiable"
      end
      resolved_parameter
    end

    # Returns group unit of the notifications from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Object] Group unit of the notifications
    def notification_group(target_type, key = nil)
      resolve_parameter(
        "notification_group_for_#{cast_to_resources_name(target_type)}",
        _notification_group[cast_to_resources_sym(target_type)],
        nil,
        key)
    end

    # Returns group expiry period of the notifications from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Object] Group expiry period of the notifications
    def notification_group_expiry_delay(target_type, key = nil)
      resolve_parameter(
        "notification_group_expiry_delay_for_#{cast_to_resources_name(target_type)}",
        _notification_group_expiry_delay[cast_to_resources_sym(target_type)],
        nil,
        key)
    end

    # Returns additional notification parameters from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Hash] Additional notification parameters
    def notification_parameters(target_type, key = nil)
      resolve_parameter(
        "notification_parameters_for_#{cast_to_resources_name(target_type)}",
        _notification_parameters[cast_to_resources_sym(target_type)],
        {},
        key)
    end

    # Returns notifier of the notification from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Object] Notifier of the notification
    def notifier(target_type, key = nil)
      resolve_parameter(
        "notifier_for_#{cast_to_resources_name(target_type)}",
        _notifier[cast_to_resources_sym(target_type)],
        nil,
        key)
    end

    # Returns if sending notification email is allowed for the notifiable from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [Object] target Target instance to notify
    # @param [String] key Key of the notification
    # @return [Boolean] If sending notification email is allowed for the notifiable
    def notification_email_allowed?(target, key = nil)
      resolve_parameter(
        "notification_email_allowed_for_#{cast_to_resources_name(target.class)}?",
        _notification_email_allowed[cast_to_resources_sym(target.class)],
        ActivityNotification.config.email_enabled,
        target, key)
    end

    # Returns if publishing WebSocket using ActionCable is allowed for the notifiable from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [Object] target Target instance to notify
    # @param [String] key Key of the notification
    # @return [Boolean] If publishing WebSocket using ActionCable is allowed for the notifiable
    def notification_action_cable_allowed?(target, key = nil)
      resolve_parameter(
        "notification_action_cable_allowed_for_#{cast_to_resources_name(target.class)}?",
        _notification_action_cable_allowed[cast_to_resources_sym(target.class)],
        ActivityNotification.config.action_cable_enabled,
        target, key)
    end

    # Returns notifiable_path to move after opening notification from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [String] Notifiable path URL to move after opening notification
    def notifiable_path(target_type, key = nil)
      resolved_parameter = resolve_parameter(
        "notifiable_path_for_#{cast_to_resources_name(target_type)}",
        _notifiable_path[cast_to_resources_sym(target_type)],
        nil,
        key)
      unless resolved_parameter
        begin
          resolved_parameter = defined?(super) ? super : polymorphic_path(self)
        rescue NoMethodError, ActionController::UrlGenerationError
          raise NotImplementedError, "You have to implement #{self.class}##{__method__}, "\
                                     "set :notifiable_path in acts_as_notifiable or "\
                                     "set polymorphic_path routing for #{self.class}"
        end
      end
      resolved_parameter
    end

    # Returns printable notifiable model name to show in view or email.
    # @return [String] Printable notifiable model name
    def printable_notifiable_name(target, key = nil)
      resolve_parameter(
        "printable_notifiable_name_for_#{cast_to_resources_name(target.class)}?",
        _printable_notifiable_name[cast_to_resources_sym(target.class)],
        printable_name,
        target, key)
    end

    # Returns optional_targets of the notification from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Array<ActivityNotification::OptionalTarget::Base>] Array of optional target instances
    def optional_targets(target_type, key = nil)
      resolve_parameter(
        "optional_targets_for_#{cast_to_resources_name(target_type)}",
        _optional_targets[cast_to_resources_sym(target_type)],
        [],
        key)
    end

    # Returns optional_target names of the notification from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] target_type Target type to notify
    # @param [String] key Key of the notification
    # @return [Array<Symbol>] Array of optional target names
    def optional_target_names(target_type, key = nil)
      optional_targets(target_type, key).map { |optional_target| optional_target.to_optional_target_name }
    end

    # overriding_notification_template_key is the method to override key definition for Renderable
    # When respond_to?(:overriding_notification_template_key) returns true,
    # Renderable uses overriding_notification_template_key instead of original key.
    #
    # overriding_notification_template_key(target, key)

    # overriding_notification_email_key is the method to override key definition for Mailer
    # When respond_to?(:overriding_notification_email_key) returns true,
    # Mailer uses overriding_notification_email_key instead of original key.
    #
    # overriding_notification_email_key(target, key)

    # overriding_notification_email_subject is the method to override subject definition for Mailer
    # When respond_to?(:overriding_notification_email_subject) returns true,
    # Mailer uses overriding_notification_email_subject instead of configured notification subject in locale file.
    #
    # overriding_notification_email_subject(target, key)


    # Generates notifications to configured targets with notifiable model.
    # This method calls NotificationApi#notify internally with self notifiable instance.
    # @see NotificationApi#notify
    #
    # @param [Symbol, String, Class] target_type Type of target
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Array<Notificaion>] Array of generated notifications
    def notify(target_type, options = {})
      Notification.notify(target_type, self, options)
    end

    # Generates notifications to configured targets with notifiable model later by ActiveJob queue.
    # This method calls NotificationApi#notify_later internally with self notifiable instance.
    # @see NotificationApi#notify_later
    #
    # @param [Symbol, String, Class] target_type Type of target
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Array<Notificaion>] Array of generated notifications
    def notify_later(target_type, options = {})
      Notification.notify_later(target_type, self, options)
    end
    alias_method :notify_now, :notify

    # Generates notifications to one target.
    # This method calls NotificationApi#notify_all internally with self notifiable instance.
    # @see NotificationApi#notify_all
    #
    # @param [Array<Object>] targets Targets to send notifications
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Array<Notificaion>] Array of generated notifications
    def notify_all(targets, options = {})
      Notification.notify_all(targets, self, options)
    end
    alias_method :notify_all_now, :notify_all

    # Generates notifications to one target later by ActiveJob queue.
    # This method calls NotificationApi#notify_all_later internally with self notifiable instance.
    # @see NotificationApi#notify_all_later
    #
    # @param [Array<Object>] targets Targets to send notifications
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Array<Notificaion>] Array of generated notifications
    def notify_all_later(targets, options = {})
      Notification.notify_all_later(targets, self, options)
    end

    # Generates notifications to one target.
    # This method calls NotificationApi#notify_to internally with self notifiable instance.
    # @see NotificationApi#notify_to
    #
    # @param [Object] target Target to send notifications
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Notification] Generated notification instance
    def notify_to(target, options = {})
      Notification.notify_to(target, self, options)
    end
    alias_method :notify_now_to, :notify_to

    # Generates notifications to one target later by ActiveJob queue.
    # This method calls NotificationApi#notify_later_to internally with self notifiable instance.
    # @see NotificationApi#notify_later_to
    #
    # @param [Object] target Target to send notifications
    # @param [Hash] options Options for notifications
    # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
    # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
    # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
    # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
    # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
    # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
    # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
    # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
    # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
    # @return [Notification] Generated notification instance
    def notify_later_to(target, options = {})
      Notification.notify_later_to(target, self, options)
    end

    # Returns default key of the notification.
    # This method is able to be overridden.
    # "#{to_resource_name}.default" is defined as default key.
    #
    # @return [String] Default key of the notification
    def default_notification_key
      "#{to_resource_name}.default"
    end

    # Returns key of the notification for tracked notifiable creation.
    # This method is able to be overridden.
    # "#{to_resource_name}.create" is defined as default creation key.
    #
    # @return [String] Key of the notification for tracked notifiable creation
    def notification_key_for_tracked_creation
      "#{to_resource_name}.create"
    end

    # Returns key of the notification for tracked notifiable update.
    # This method is able to be overridden.
    # "#{to_resource_name}.update" is defined as default update key.
    #
    # @return [String] Key of the notification for tracked notifiable update
    def notification_key_for_tracked_update
      "#{to_resource_name}.update"
    end

    private

      # Used to transform parameter value from configured field or defined method.
      # @api private
      #
      # @param [String] target_typed_method_name Method name overridden for the target type
      # @param [Object] parameter_field Parameter Configured field in this model
      # @param [Object] default_value Default parameter value
      # @param [Array] args Arguments to pass to the method overridden or defined as parameter field
      # @return [Object] Resolved parameter value
      def resolve_parameter(target_typed_method_name, parameter_field, default_value, *args)
        if respond_to?(target_typed_method_name)
          send(target_typed_method_name, *args)
        elsif parameter_field
          resolve_value(parameter_field, *args)
        else
          default_value
        end
      end

      # Gets generated notifications for specified target type.
      # @api private
      # @param [String] target_type Target type of generated notifications
      def generated_notifications_as_notifiable_for(target_type = nil)
        target_type.nil? ?
          generated_notifications_as_notifiable.all :
          generated_notifications_as_notifiable.filtered_by_target_type(target_type.to_s.to_model_name)
      end

      # Destroies generated notifications for specified target type with dependency.
      # This method is intended to be called before destroy this notifiable as dependent configuration.
      # @api private
      # @param [Symbol]  dependent         Has_many dependency, [:delete_all, :destroy, :restrict_with_error, :restrict_with_exception] are available
      # @param [String]  target_type       Target type of generated notifications
      # @param [Boolean] remove_from_group Whether it removes generated notifications from notification group before destroy
      def destroy_generated_notifications_with_dependency(dependent = :delete_all, target_type = nil, remove_from_group = false)
        remove_generated_notifications_from_group(target_type) if remove_from_group
        generated_notifications = generated_notifications_as_notifiable_for(target_type)
        case dependent
        when :restrict_with_exception
          ActivityNotification::Notification.raise_delete_restriction_error("generated_notifications_as_notifiable_for_#{target_type.to_s.pluralize.underscore}") unless generated_notifications.to_a.empty?
        when :restrict_with_error
          unless generated_notifications.to_a.empty?
            record = self.class.human_attribute_name("generated_notifications_as_notifiable_for_#{target_type.to_s.pluralize.underscore}").downcase
            self.errors.add(:base, :'restrict_dependent_destroy.has_many', record: record)
            if Rails::VERSION::MAJOR >= 5 then throw(:abort) else false end
          end
        when :destroy
          generated_notifications.each { |n| n.destroy }
        when :delete_all
          generated_notifications.delete_all
        end
      end

      # Removes generated notifications from notification group to new group owner.
      # This method is intended to be called before destroy this notifiable as dependent configuration.
      # @api private
      # @param [String]  target_type       Target type of generated notifications
      def remove_generated_notifications_from_group(target_type = nil)
        generated_notifications_as_notifiable_for(target_type).group_owners_only.each { |n| n.remove_from_group }
      end

      # Casts to resources name.
      # @api private
      def cast_to_resources_name(target_type)
        target_type.to_s.to_resources_name
      end

      # Casts to symbol of resources name.
      # @api private
      def cast_to_resources_sym(target_type)
        target_type.to_s.to_resources_name.to_sym
      end
  end
end