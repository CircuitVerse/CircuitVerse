module ActivityNotification
  # Target implementation included in target model to notify, like users or administrators.
  module Target
    extend ActiveSupport::Concern

    included do
      include Common
      include Association

      # Has many notification instances of this target.
      # @scope instance
      # @return [Array<Notificaion>, Mongoid::Criteria<Notificaion>] Array or database query of notifications of this target
      has_many_records :notifications,
        class_name: "::ActivityNotification::Notification",
        as: :target,
        dependent: :delete_all

      class_attribute :_notification_email,
                      :_notification_email_allowed,
                      :_batch_notification_email_allowed,
                      :_notification_subscription_allowed,
                      :_notification_action_cable_allowed,
                      :_notification_action_cable_with_devise,
                      :_notification_devise_resource,
                      :_notification_current_devise_target,
                      :_printable_notification_target_name
      set_target_class_defaults
    end

    class_methods do
      # Checks if the model includes target and target methods are available.
      # @return [Boolean] Always true
      def available_as_target?
        true
      end

      # Sets default values to target class fields.
      # @return [NilClass] nil
      def set_target_class_defaults
        self._notification_email                    = nil
        self._notification_email_allowed            = ActivityNotification.config.email_enabled
        self._batch_notification_email_allowed      = ActivityNotification.config.email_enabled
        self._notification_subscription_allowed     = ActivityNotification.config.subscription_enabled
        self._notification_action_cable_allowed     = ActivityNotification.config.action_cable_enabled || ActivityNotification.config.action_cable_api_enabled
        self._notification_action_cable_with_devise = ActivityNotification.config.action_cable_with_devise
        self._notification_devise_resource          = ->(model) { model }
        self._notification_current_devise_target    = ->(current_resource) { current_resource }
        self._printable_notification_target_name    = :printable_name
        nil
      end

      # Gets all notifications for this target type.
      #
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
      # @option options [String]     :filtered_by_status     (:all)  Status for filter, :all, :opened and :unopened are available
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [Array<Notificaion>] All notifications for this target type
      def all_notifications(options = {})
        reverse                = options[:reverse] || false
        with_group_members     = options[:with_group_members] || false
        as_latest_group_member = options[:as_latest_group_member] || false
        target_notifications = Notification.filtered_by_target_type(self.name)
                                           .all_index!(reverse, with_group_members)
                                           .filtered_by_options(options)
                                           .with_target
        case options[:filtered_by_status]
        when :opened, 'opened'
          target_notifications = target_notifications.opened_only!
        when :unopened, 'unopened'
          target_notifications = target_notifications.unopened_only
        end
        target_notifications = target_notifications.limit(options[:limit]) if options[:limit].present?
        as_latest_group_member ?
          target_notifications.latest_order!(reverse).map{ |n| n.latest_group_member } :
          target_notifications.latest_order!(reverse).to_a
      end

      # Gets all notifications for this target type grouped by targets.
      #
      # @example Get all notifications for for users grouped by user
      #   @notification_index_map = User.notification_index_map
      #   @notification_index_map.each do |user, notifications|
      #     # Do something for user and notifications
      #   end
      #
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
      # @option options [String]     :filtered_by_status     (:all)  Status for filter, :all, :opened and :unopened are available
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [Hash<Target, Notificaion>] All notifications for this target type grouped by targets
      def notification_index_map(options = {})
        all_notifications(options).group_by(&:target)
      end

      # Send batch notification email to this type targets with unopened notifications.
      #
      # @example Send batch notification email to the users with unopened notifications of specified key
      #   User.send_batch_unopened_notification_email(filtered_by_key: 'this.key')
      # @example Send batch notification email to the users with unopened notifications of specified key in 1 hour
      #   User.send_batch_unopened_notification_email(filtered_by_key: 'this.key', custom_filter: ["created_at >= ?", time.hour.ago])
      #
      # @option options [Integer]        :limit                  (nil)            Limit to query for notifications
      # @option options [Boolean]        :reverse                (false)          If notification index will be ordered as earliest first
      # @option options [Boolean]        :with_group_members     (false)          If notification index will include group members
      # @option options [Boolean]        :as_latest_group_member (false)          If grouped notification will be shown as the latest group member (default is shown as the earliest member)
      # @option options [String]         :filtered_by_type       (nil)            Notifiable type for filter
      # @option options [Object]         :filtered_by_group      (nil)            Group instance for filter
      # @option options [String]         :filtered_by_group_type (nil)            Group type for filter, valid with :filtered_by_group_id
      # @option options [String]         :filtered_by_group_id   (nil)            Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]         :filtered_by_key        (nil)            Key of the notification for filter
      # @option options [String]         :later_than             (nil)            ISO 8601 format time to filter notifications later than specified time
      # @option options [String]         :earlier_than           (nil)            ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash]     :custom_filter          (nil)            Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @option options [Boolean]        :send_later             (false)          If it sends notification email asynchronously
      # @option options [String, Symbol] :fallback               (:batch_default) Fallback template to use when MissingTemplate is raised
      # @option options [String]         :batch_key              (nil)            Key of the batch notification email, a key of the first notification will be used if not specified
      # @return [Hash<Object, Mail::Message|ActionMailer::DeliveryJob>] Hash of target and sent email message or its delivery job
      def send_batch_unopened_notification_email(options = {})
        unopened_notification_index_map = notification_index_map(options.merge(filtered_by_status: :unopened))
        mailer_options = options.select { |k, _| [:send_later, :fallback, :batch_key].include?(k) }
        unopened_notification_index_map.map { |target, notifications|
          [target, Notification.send_batch_notification_email(target, notifications, mailer_options)]
        }.to_h
      end

      # Resolves current authenticated target by devise authentication from current resource signed in with Devise.
      # This method is able to be overridden.
      #
      # @param [Object] current_resource Current resource signed in with Devise
      # @return [Object] Current authenticated target by devise authentication
      def resolve_current_devise_target(current_resource)
        _notification_current_devise_target.call(current_resource)
      end

      # Returns if subscription management is allowed for this target type.
      # @return [Boolean] If subscription management is allowed for this target type
      def subscription_enabled?
        _notification_subscription_allowed ? true : false
      end
      alias_method :notification_subscription_enabled?, :subscription_enabled?
    end

    # Returns target email address for email notification.
    # This method is able to be overridden.
    #
    # @return [String] Target email address
    def mailer_to
      resolve_value(_notification_email)
    end

    # Returns if sending notification email is allowed for the target from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [Object] notifiable Notifiable instance of the notification
    # @param [String] key Key of the notification
    # @return [Boolean] If sending notification email is allowed for the target
    def notification_email_allowed?(notifiable, key)
      resolve_value(_notification_email_allowed, notifiable, key)
    end

    # Returns if sending batch notification email is allowed for the target from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] key Key of the notifications
    # @return [Boolean] If sending batch notification email is allowed for the target
    def batch_notification_email_allowed?(key)
      resolve_value(_batch_notification_email_allowed, key)
    end

    # Returns if subscription management is allowed for the target from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [String] key Key of the notifications
    # @return [Boolean] If subscription management is allowed for the target
    def subscription_allowed?(key)
      resolve_value(_notification_subscription_allowed, key)
    end
    alias_method :notification_subscription_allowed?, :subscription_allowed?

    # Returns if publishing WebSocket using ActionCable is allowed for the target from configured field or overridden method.
    # This method is able to be overridden.
    #
    # @param [Object] notifiable Notifiable instance of the notification
    # @param [String] key Key of the notification
    # @return [Boolean] If publishing WebSocket using ActionCable is allowed for the target
    def notification_action_cable_allowed?(notifiable = nil, key = nil)
      resolve_value(_notification_action_cable_allowed, notifiable, key)
    end

    # Returns if publishing WebSocket using ActionCable is allowed only for the authenticated target with Devise from configured field or overridden method.
    #
    # @return [Boolean] If publishing WebSocket using ActionCable is allowed for the target
    def notification_action_cable_with_devise?
      resolve_value(_notification_action_cable_with_devise)
    end

    # Returns notification ActionCable channel class name from action_cable_with_devise? configuration.
    #
    # @return [String] Notification ActionCable channel class name from action_cable_with_devise? configuration
    def notification_action_cable_channel_class_name
      notification_action_cable_with_devise? ? "ActivityNotification::NotificationWithDeviseChannel" : "ActivityNotification::NotificationChannel"
    end

    # Returns Devise resource model associated with this target.
    #
    # @return [Object] Devise resource model associated with this target
    def notification_devise_resource
      resolve_value(_notification_devise_resource)
    end

    # Returns if current resource signed in with Devise is authenticated for the notification.
    # This method is able to be overridden.
    #
    # @param [Object] current_resource Current resource signed in with Devise
    # @return [Boolean] If current resource signed in with Devise is authenticated for the notification
    def authenticated_with_devise?(current_resource)
      devise_resource = notification_devise_resource
      unless current_resource.blank? or current_resource.is_a? devise_resource.class
        raise TypeError,
          "Different type of current resource #{current_resource.class} "\
          "with devise resource #{devise_resource.class} has been passed to #{self.class}##{__method__}. "\
          "You have to override #{self.class}##{__method__} method or set devise_resource in acts_as_target."
      end
      current_resource.present? && current_resource == devise_resource
    end

    # Returns printable target model name to show in view or email.
    # @return [String] Printable target model name
    def printable_target_name
      resolve_value(_printable_notification_target_name)
    end

    # Returns count of unopened notifications of the target.
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Integer] Count of unopened notifications of the target
    def unopened_notification_count(options = {})
      target_notifications = _unopened_notification_index(options)
      target_notifications.present? ? target_notifications.count : 0
    end

    # Returns if the target has unopened notifications.
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Boolean] If the target has unopened notifications
    def has_unopened_notifications?(options = {})
      _unopened_notification_index(options).exists?
    end

    # Returns automatically arranged notification index of the target.
    # This method is the typical way to get notification index from controller and view.
    # When the target has unopened notifications, it returns unopened notifications first.
    # Additionaly, it returns opened notifications unless unopened index size overs the limit.
    # @todo Is this conbimned array the best solution?
    #
    # @example Get automatically arranged notification index of @user
    #   @notifications = @user.notification_index
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Notification index of the target
    def notification_index(options = {})
      arrange_notification_index(method(:unopened_notification_index),
                                 method(:opened_notification_index),
                                 options)
    end

    # Returns unopened notification index of the target.
    #
    # @example Get unopened notification index of @user
    #   @notifications = @user.unopened_notification_index
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Unopened notification index of the target
    def unopened_notification_index(options = {})
      arrange_single_notification_index(method(:_unopened_notification_index), options)
    end

    # Returns opened notification index of the target.
    #
    # @example Get opened notification index of @user
    #   @notifications = @user.opened_notification_index(10)
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Opened notification index of the target
    def opened_notification_index(options = {})
      arrange_single_notification_index(method(:_opened_notification_index), options)
    end

    # Generates notifications to this target.
    # This method calls NotificationApi#notify_to internally with self target instance.
    # @see NotificationApi#notify_to
    #
    # @param [Object] notifiable Notifiable instance to notify
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
    def receive_notification_of(notifiable, options = {})
      Notification.notify_to(self, notifiable, options)
    end
    alias_method :receive_notification_now_of, :receive_notification_of

    # Generates notifications to this target later by ActiveJob queue.
    # This method calls NotificationApi#notify_later_to internally with self target instance.
    # @see NotificationApi#notify_later_to
    #
    # @param [Object] notifiable Notifiable instance to notify
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
    def receive_notification_later_of(notifiable, options = {})
      Notification.notify_later_to(self, notifiable, options)
    end

    # Opens all notifications of this target.
    # This method calls NotificationApi#open_all_of internally with self target instance.
    # @see NotificationApi#open_all_of
    #
    # @param [Hash] options Options for opening notifications
    # @option options [DateTime] :opened_at              (Time.current) Time to set to opened_at of the notification record
    # @option options [String]   :filtered_by_type       (nil)          Notifiable type for filter
    # @option options [Object]   :filtered_by_group      (nil)          Group instance for filter
    # @option options [String]   :filtered_by_group_type (nil)          Group type for filter, valid with :filtered_by_group_id
    # @option options [String]   :filtered_by_group_id   (nil)          Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]   :filtered_by_key        (nil)          Key of the notification for filter
    # @option options [String]   :later_than             (nil)          ISO 8601 format time to filter notifications later than specified time
    # @option options [String]   :earlier_than           (nil)          ISO 8601 format time to filter notifications earlier than specified time
    # @return [Array<Notification>] Opened notification records
    def open_all_notifications(options = {})
      Notification.open_all_of(self, options)
    end


    # Gets automatically arranged notification index of the target with included attributes like target, notifiable, group and notifier.
    # This method is the typical way to get notifications index from controller of view.
    # When the target have unopened notifications, it returns unopened notifications first.
    # Additionaly, it returns opened notifications unless unopened index size overs the limit.
    # @todo Is this switching the best solution?
    #
    # @example Get automatically arranged notification index of the @user with included attributes
    #   @notifications = @user.notification_index_with_attributes
    #
    # @param [Hash] options Options for notification index
    # @option options [Boolean]        :send_later             (false)          If it sends notification email asynchronously
    # @option options [String, Symbol] :fallback               (:batch_default) Fallback template to use when MissingTemplate is raised
    # @option options [String]         :batch_key              (nil)            Key of the batch notification email, a key of the first notification will be used if not specified
    # @option options [Integer]        :limit                  (nil)           Limit to query for notifications
    # @option options [Boolean]        :reverse                (false)         If notification index will be ordered as earliest first
    # @option options [Boolean]        :with_group_members     (false)         If notification index will include group members
    # @option options [Boolean]        :as_latest_group_member (false)         If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]         :filtered_by_type       (nil)           Notifiable type for filter
    # @option options [Object]         :filtered_by_group      (nil)           Group instance for filter
    # @option options [String]         :filtered_by_group_type (nil)           Group type for filter, valid with :filtered_by_group_id
    # @option options [String]         :filtered_by_group_id   (nil)           Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]         :filtered_by_key        (nil)           Key of the notification for filter
    # @option options [String]         :later_than             (nil)           ISO 8601 format time to filter notifications later than specified time
    # @option options [String]         :earlier_than           (nil)           ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash]     :custom_filter          (nil)           Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Notification index of the target with attributes
    def notification_index_with_attributes(options = {})
      arrange_notification_index(method(:unopened_notification_index_with_attributes),
                                 method(:opened_notification_index_with_attributes),
                                 options)
    end

    # Gets unopened notification index of the target with included attributes like target, notifiable, group and notifier.
    #
    # @example Get unopened notification index of the @user with included attributes
    #   @notifications = @user.unopened_notification_index_with_attributes
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Unopened notification index of the target with attributes
    def unopened_notification_index_with_attributes(options = {})
      include_attributes(_unopened_notification_index(options)).to_a
    end

    # Gets opened notification index of the target with including attributes like target, notifiable, group and notifier.
    #
    # @example Get opened notification index of the @user with included attributes
    #   @notifications = @user.opened_notification_index_with_attributes(10)
    #
    # @param [Hash] options Options for notification index
    # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
    # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
    # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
    # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
    # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
    # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
    # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
    # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
    # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
    # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
    # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [Array<Notificaion>] Opened notification index of the target with attributes
    def opened_notification_index_with_attributes(options = {})
      include_attributes(_opened_notification_index(options)).to_a
    end

    # Sends notification email to the target.
    #
    # @param [Hash] options Options for notification email
    # @option options [Boolean]        :send_later            If it sends notification email asynchronously
    # @option options [String, Symbol] :fallback   (:default) Fallback template to use when MissingTemplate is raised
    # @return [Mail::Message|ActionMailer::DeliveryJob] Email message or its delivery job, return NilClass for wrong target
    def send_notification_email(notification, options = {})
      if notification.target == self
        notification.send_notification_email(options)
      end
    end

    # Sends batch notification email to the target.
    #
    # @param [Array<Notification>] notifications Target notifications to send batch notification email
    # @param [Hash]                options       Options for notification email
    # @option options [Boolean]        :send_later  (false)          If it sends notification email asynchronously
    # @option options [String, Symbol] :fallback    (:batch_default) Fallback template to use when MissingTemplate is raised
    # @option options [String]         :batch_key   (nil)            Key of the batch notification email, a key of the first notification will be used if not specified
    # @return [Mail::Message|ActionMailer::DeliveryJob|NilClass] Email message or its delivery job, return NilClass for wrong target
    def send_batch_notification_email(notifications, options = {})
      return if notifications.blank?
      if notifications.map{ |n| n.target }.uniq == [self]
        Notification.send_batch_notification_email(self, notifications, options)
      end
    end

    # Returns if the target subscribes to the notification.
    # It also returns true when the subscription management is not allowed for the target.
    #
    # @param [String]  key                  Key of the notification
    # @param [Boolean] subscribe_as_default Default subscription value to use when the subscription record does not configured
    # @return [Boolean] If the target subscribes the notification or the subscription management is not allowed for the target
    def subscribes_to_notification?(key, subscribe_as_default = ActivityNotification.config.subscribe_as_default)
      !subscription_allowed?(key) || _subscribes_to_notification?(key, subscribe_as_default)
    end

    # Returns if the target subscribes to the notification email.
    # It also returns true when the subscription management is not allowed for the target.
    #
    # @param [String]  key                  Key of the notification
    # @param [Boolean] subscribe_as_default Default subscription value to use when the subscription record does not configured
    # @return [Boolean] If the target subscribes the notification email or the subscription management is not allowed for the target
    def subscribes_to_notification_email?(key, subscribe_as_default = ActivityNotification.config.subscribe_to_email_as_default)
      !subscription_allowed?(key) || _subscribes_to_notification_email?(key, subscribe_as_default)
    end
    alias_method :subscribes_to_email?, :subscribes_to_notification_email?

    # Returns if the target subscribes to the specified optional target.
    # It also returns true when the subscription management is not allowed for the target.
    #
    # @param [String]         key                  Key of the notification
    # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
    # @param [Boolean]        subscribe_as_default Default subscription value to use when the subscription record does not configured
    # @return [Boolean] If the target subscribes the notification email or the subscription management is not allowed for the target
    def subscribes_to_optional_target?(key, optional_target_name, subscribe_as_default = ActivityNotification.config.subscribe_to_optional_targets_as_default)
      !subscription_allowed?(key) || _subscribes_to_optional_target?(key, optional_target_name, subscribe_as_default)
    end

    private

      # Gets unopened notification index of the target as ActiveRecord.
      # @api private
      #
      # @param [Hash] options Options for notification index
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [ActiveRecord_AssociationRelation<Notificaion>|Mongoid::Criteria<Notificaion>|Dynamoid::Criteria::Chain] Unopened notification index of the target
      def _unopened_notification_index(options = {})
        reverse            = options[:reverse] || false
        with_group_members = options[:with_group_members] || false
        target_index = notifications.unopened_index(reverse, with_group_members).filtered_by_options(options)
        options[:limit].present? ? target_index.limit(options[:limit]) : target_index
      end

      # Gets opened notification index of the target as ActiveRecord.
      #
      # @param [Hash] options Options for notification index
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [ActiveRecord_AssociationRelation<Notificaion>|Mongoid::Criteria<Notificaion>|Dynamoid::Criteria::Chain] Opened notification index of the target
      def _opened_notification_index(options = {})
        limit              = options[:limit] || ActivityNotification.config.opened_index_limit
        reverse            = options[:reverse] || false
        with_group_members = options[:with_group_members] || false
        notifications.opened_index(limit, reverse, with_group_members).filtered_by_options(options)
      end

      # Includes attributes like target, notifiable, group or notifier from the notification index.
      # When group member exists in the notification index, group will be included in addition to target, notifiable and or notifier.
      # Otherwise, target, notifiable and or notifier will be include without group.
      # @api private
      #
      # @param [ActiveRecord_AssociationRelation<Notificaion>|Mongoid::Criteria<Notificaion>|Dynamoid::Criteria::Chain] target_index Notification index
      # @return [ActiveRecord_AssociationRelation<Notificaion>|Mongoid::Criteria<Notificaion>|Dynamoid::Criteria::Chain] Notification index with attributes
      def include_attributes(target_index)
        if target_index.present?
          Notification.group_member_exists?(target_index.to_a) ?
            target_index.with_target.with_notifiable.with_group.with_notifier :
            target_index.with_target.with_notifiable.with_notifier
        else
          Notification.none
        end
      end

      # Gets arranged single notification index of the target.
      # @api private
      #
      # @param [Method] loading_index_method Method to load index
      # @param [Hash] options Options for notification index
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [Array<Notificaion>] Notification index of the target
      def arrange_single_notification_index(loading_index_method, options = {})
        as_latest_group_member = options[:as_latest_group_member] || false
        as_latest_group_member ?
          loading_index_method.call(options).map{ |n| n.latest_group_member } :
          loading_index_method.call(options).to_a
      end

      # Gets automatically arranged notification index of the target.
      # When the target have unopened notifications, it returns unopened notifications first.
      # Additionaly, it returns opened notifications unless unopened index size overs the limit.
      # @api private
      # @todo Is this switching the best solution?
      #
      # @param [Method] loading_unopened_index_method Method to load unopened index
      # @param [Method] loading_opened_index_method Method to load opened index
      # @param [Hash] options Options for notification index
      # @option options [Integer]    :limit                  (nil)   Limit to query for notifications
      # @option options [Boolean]    :reverse                (false) If notification index will be ordered as earliest first
      # @option options [Boolean]    :with_group_members     (false) If notification index will include group members
      # @option options [Boolean]    :as_latest_group_member (false) If grouped notification will be shown as the latest group member (default is shown as the earliest member)
      # @option options [String]     :filtered_by_type       (nil)   Notifiable type for filter
      # @option options [Object]     :filtered_by_group      (nil)   Group instance for filter
      # @option options [String]     :filtered_by_group_type (nil)   Group type for filter, valid with :filtered_by_group_id
      # @option options [String]     :filtered_by_group_id   (nil)   Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]     :filtered_by_key        (nil)   Key of the notification for filter
      # @option options [String]     :later_than             (nil)   ISO 8601 format time to filter notifications later than specified time
      # @option options [String]     :earlier_than           (nil)   ISO 8601 format time to filter notifications earlier than specified time
      # @option options [Array|Hash] :custom_filter          (nil)   Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
      # @return [Array<Notificaion>] Notification index of the target
      def arrange_notification_index(loading_unopened_index_method, loading_opened_index_method, options = {})
        # When the target have unopened notifications
        if has_unopened_notifications?(options)
          # Return unopened notifications first
          target_unopened_index = arrange_single_notification_index(loading_unopened_index_method, options)
          # Total limit of notification index
          total_limit = options[:limit] || ActivityNotification.config.opened_index_limit
          # Additionaly, return opened notifications unless unopened index size overs the limit
          if (opened_limit = total_limit - target_unopened_index.size) > 0
            target_opened_index = arrange_single_notification_index(loading_opened_index_method, options.merge(limit: opened_limit))
            target_unopened_index.concat(target_opened_index.to_a)
          else
            target_unopened_index
          end
        else
          # Otherwise, return opened notifications
          arrange_single_notification_index(loading_opened_index_method, options)
        end
      end

  end
end
