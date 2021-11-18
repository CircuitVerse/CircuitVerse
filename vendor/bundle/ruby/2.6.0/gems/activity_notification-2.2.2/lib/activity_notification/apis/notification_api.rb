module ActivityNotification
  # Defines API for notification included in Notification model.
  module NotificationApi
    extend ActiveSupport::Concern

    included do
      # Defines store_notification as private clas method
      private_class_method :store_notification

      # Defines mailer class to send notification
      set_notification_mailer

      # :nocov:
      unless ActivityNotification.config.orm == :dynamoid
        # Selects all notification index.
        #   ActivityNotification::Notification.all_index!
        # is defined same as
        #   ActivityNotification::Notification.group_owners_only.latest_order
        # @scope class
        # @example Get all notification index of the @user
        #   @notifications = @user.notifications.all_index!
        #   @notifications = @user.notifications.group_owners_only.latest_order
        # @param [Boolean] reverse If notification index will be ordered as earliest first
        # @param [Boolean] with_group_members If notification index will include group members
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :all_index!,                        ->(reverse = false, with_group_members = false) {
          target_index = with_group_members ? self : group_owners_only
          reverse ? target_index.earliest_order : target_index.latest_order
        }

        # Selects unopened notification index.
        #   ActivityNotification::Notification.unopened_index
        # is defined same as
        #   ActivityNotification::Notification.unopened_only.group_owners_only.latest_order
        # @scope class
        # @example Get unopened notificaton index of the @user
        #   @notifications = @user.notifications.unopened_index
        #   @notifications = @user.notifications.unopened_only.group_owners_only.latest_order
        # @param [Boolean] reverse If notification index will be ordered as earliest first
        # @param [Boolean] with_group_members If notification index will include group members
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :unopened_index,                    ->(reverse = false, with_group_members = false) {
          target_index = with_group_members ? unopened_only : unopened_only.group_owners_only
          reverse ? target_index.earliest_order : target_index.latest_order
        }

        # Selects unopened notification index.
        #   ActivityNotification::Notification.opened_index(limit)
        # is defined same as
        #   ActivityNotification::Notification.opened_only(limit).group_owners_only.latest_order
        # @scope class
        # @example Get unopened notificaton index of the @user with limit 10
        #   @notifications = @user.notifications.opened_index(10)
        #   @notifications = @user.notifications.opened_only(10).group_owners_only.latest_order
        # @param [Integer] limit Limit to query for opened notifications
        # @param [Boolean] reverse If notification index will be ordered as earliest first
        # @param [Boolean] with_group_members If notification index will include group members
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :opened_index,                      ->(limit, reverse = false, with_group_members = false) {
          target_index = with_group_members ? opened_only(limit) : opened_only(limit).group_owners_only
          reverse ? target_index.earliest_order : target_index.latest_order
        }

        # Selects filtered notifications by target_type.
        # @example Get filtered unopened notificatons of User as target type
        #   @notifications = ActivityNotification.Notification.unopened_only.filtered_by_target_type('User')
        # @scope class
        # @param [String] target_type Target type for filter
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :filtered_by_target_type,           ->(target_type) { where(target_type: target_type) }

        # Selects filtered notifications by notifiable_type.
        # @example Get filtered unopened notificatons of the @user for Comment notifiable class
        #   @notifications = @user.notifications.unopened_only.filtered_by_type('Comment')
        # @scope class
        # @param [String] notifiable_type Notifiable type for filter
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :filtered_by_type,                  ->(notifiable_type) { where(notifiable_type: notifiable_type) }

        # Selects filtered notifications by key.
        # @example Get filtered unopened notificatons of the @user with key 'comment.reply'
        #   @notifications = @user.notifications.unopened_only.filtered_by_key('comment.reply')
        # @scope class
        # @param [String] key Key of the notification for filter
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :filtered_by_key,                   ->(key) { where(key: key) }

        # Selects filtered notifications by notifiable_type, group or key with filter options.
        # @example Get filtered unopened notificatons of the @user for Comment notifiable class
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ filtered_by_type: 'Comment' })
        # @example Get filtered unopened notificatons of the @user for @article as group
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ filtered_by_group: @article })
        # @example Get filtered unopened notificatons of the @user for Article instance id=1 as group
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ filtered_by_group_type: 'Article', filtered_by_group_id: '1' })
        # @example Get filtered unopened notificatons of the @user with key 'comment.reply'
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ filtered_by_key: 'comment.reply' })
        # @example Get filtered unopened notificatons of the @user for Comment notifiable class with key 'comment.reply'
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ filtered_by_type: 'Comment', filtered_by_key: 'comment.reply' })
        # @example Get custom filtered notificatons of the @user
        #   @notifications = @user.notifications.unopened_only.filtered_by_options({ custom_filter: ["created_at >= ?", time.hour.ago] })
        # @scope class
        # @param [Hash] options Options for filter
        # @option options [String]     :filtered_by_type       (nil) Notifiable type for filter
        # @option options [Object]     :filtered_by_group      (nil) Group instance for filter
        # @option options [String]     :filtered_by_group_type (nil) Group type for filter, valid with :filtered_by_group_id
        # @option options [String]     :filtered_by_group_id   (nil) Group instance id for filter, valid with :filtered_by_group_type
        # @option options [String]     :filtered_by_key        (nil) Key of the notification for filter
        # @option options [String]     :later_than             (nil) ISO 8601 format time to filter notification index later than specified time
        # @option options [String]     :earlier_than           (nil) ISO 8601 format time to filter notification index earlier than specified time
        # @option options [Array|Hash] :custom_filter          (nil) Custom notification filter (e.g. ["created_at >= ?", time.hour.ago] with ActiveRecord or {:created_at.gt => time.hour.ago} with Mongoid)
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of filtered notifications
        scope :filtered_by_options,               ->(options = {}) {
          options = ActivityNotification.cast_to_indifferent_hash(options)
          filtered_notifications = all
          if options.has_key?(:filtered_by_type)
            filtered_notifications = filtered_notifications.filtered_by_type(options[:filtered_by_type])
          end
          if options.has_key?(:filtered_by_group)
            filtered_notifications = filtered_notifications.filtered_by_group(options[:filtered_by_group])
          end
          if options.has_key?(:filtered_by_group_type) && options.has_key?(:filtered_by_group_id)
            filtered_notifications = filtered_notifications
                                     .where(group_type: options[:filtered_by_group_type], group_id: options[:filtered_by_group_id])
          end
          if options.has_key?(:filtered_by_key)
            filtered_notifications = filtered_notifications.filtered_by_key(options[:filtered_by_key])
          end
          if options.has_key?(:later_than)
            filtered_notifications = filtered_notifications.later_than(Time.iso8601(options[:later_than]))
          end
          if options.has_key?(:earlier_than)
            filtered_notifications = filtered_notifications.earlier_than(Time.iso8601(options[:earlier_than]))
          end
          if options.has_key?(:custom_filter)
            filtered_notifications = filtered_notifications.where(options[:custom_filter])
          end
          filtered_notifications
        }

        # Orders by latest (newest) first as created_at: :desc.
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of notifications ordered by latest first
        scope :latest_order,                      -> { order(created_at: :desc) }

        # Orders by earliest (older) first as created_at: :asc.
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of notifications ordered by earliest first
        scope :earliest_order,                    -> { order(created_at: :asc) }

        # Orders by latest (newest) first as created_at: :desc.
        # This method is to be overridden in implementation for each ORM.
        # @param [Boolean] reverse If notifications will be ordered as earliest first
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of ordered notifications
        scope :latest_order!,                     ->(reverse = false) { reverse ? earliest_order : latest_order }

        # Orders by earliest (older) first as created_at: :asc.
        # This method is to be overridden in implementation for each ORM.
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of notifications ordered by earliest first
        scope :earliest_order!,                   -> { earliest_order }

        # Returns latest notification instance.
        # @return [Notification] Latest notification instance
        def self.latest
          latest_order.first
        end

        # Returns earliest notification instance.
        # @return [Notification] Earliest notification instance
        def self.earliest
          earliest_order.first
        end

        # Returns latest notification instance.
        # This method is to be overridden in implementation for each ORM.
        # @return [Notification] Latest notification instance
        def self.latest!
          latest
        end

        # Returns earliest notification instance.
        # This method is to be overridden in implementation for each ORM.
        # @return [Notification] Earliest notification instance
        def self.earliest!
          earliest
        end

        # Selects unique keys from query for notifications.
        # @return [Array<String>] Array of notification unique keys
        def self.uniq_keys
          ## select method cannot be chained with order by other columns like created_at
          # select(:key).distinct.pluck(:key)
          ## distinct method cannot keep original sort
          # distinct(:key)
          pluck(:key).uniq
        end
      end
      # :nocov:
    end

    class_methods do
      # Generates notifications to configured targets with notifiable model.
      #
      # @example Use with target_type as Symbol
      #   ActivityNotification::Notification.notify :users, @comment
      # @example Use with target_type as String
      #   ActivityNotification::Notification.notify 'User', @comment
      # @example Use with target_type as Class
      #   ActivityNotification::Notification.notify User, @comment
      # @example Use with options
      #   ActivityNotification::Notification.notify :users, @comment, key: 'custom.comment', group: @comment.article
      #   ActivityNotification::Notification.notify :users, @comment, parameters: { reply_to: @comment.reply_to }, send_later: false
      #
      # @param [Symbol, String, Class] target_type Type of target
      # @param [Object] notifiable Notifiable instance
      # @param [Hash] options Options for notifications
      # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
      # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
      # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
      # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
      # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
      # @option options [Boolean]                 :notify_later             (false)                               Whether it generates notifications asynchronously
      # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
      # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
      # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
      # @option options [Boolean]                 :pass_full_options        (false)                               Whether it passes full options to notifiable.notification_targets, not a key only
      # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
      # @return [Array<Notificaion>] Array of generated notifications
      def notify(target_type, notifiable, options = {})
        if options[:notify_later]
          notify_later(target_type, notifiable, options)
        else
          targets = notifiable.notification_targets(target_type, options[:pass_full_options] ? options : options[:key])
          unless targets.blank?
            notify_all(targets, notifiable, options)
          end
        end
      end
      alias_method :notify_now, :notify

      # Generates notifications to configured targets with notifiable model later by ActiveJob queue.
      #
      # @example Use with target_type as Symbol
      #   ActivityNotification::Notification.notify_later :users, @comment
      # @example Use with target_type as String
      #   ActivityNotification::Notification.notify_later 'User', @comment
      # @example Use with target_type as Class
      #   ActivityNotification::Notification.notify_later User, @comment
      # @example Use with options
      #   ActivityNotification::Notification.notify_later :users, @comment, key: 'custom.comment', group: @comment.article
      #   ActivityNotification::Notification.notify_later :users, @comment, parameters: { reply_to: @comment.reply_to }, send_later: false
      #
      # @param [Symbol, String, Class] target_type Type of target
      # @param [Object] notifiable Notifiable instance
      # @param [Hash] options Options for notifications
      # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
      # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
      # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
      # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
      # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
      # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
      # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
      # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
      # @option options [Boolean]                 :pass_full_options        (false)                               Whether it passes full options to notifiable.notification_targets, not a key only
      # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
      # @return [Array<Notificaion>] Array of generated notifications
      def notify_later(target_type, notifiable, options = {})
        target_type = target_type.to_s if target_type.is_a? Symbol
        options.delete(:notify_later)
        ActivityNotification::NotifyJob.perform_later(target_type, notifiable, options)
      end

      # Generates notifications to specified targets.
      #
      # @example Notify to all users
      #   ActivityNotification::Notification.notify_all User.all, @comment
      #
      # @param [Array<Object>] targets Targets to send notifications
      # @param [Object] notifiable Notifiable instance
      # @param [Hash] options Options for notifications
      # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
      # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
      # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
      # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
      # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
      # @option options [Boolean]                 :notify_later             (false)                               Whether it generates notifications asynchronously
      # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
      # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
      # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
      # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
      # @return [Array<Notificaion>] Array of generated notifications
      def notify_all(targets, notifiable, options = {})
        if options[:notify_later]
          notify_all_later(targets, notifiable, options)
        else
          targets.map { |target| notify_to(target, notifiable, options) }
        end
      end
      alias_method :notify_all_now, :notify_all

      # Generates notifications to specified targets later by ActiveJob queue.
      #
      # @example Notify to all users later
      #   ActivityNotification::Notification.notify_all_later User.all, @comment
      #
      # @param [Array<Object>] targets Targets to send notifications
      # @param [Object] notifiable Notifiable instance
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
      def notify_all_later(targets, notifiable, options = {})
        options.delete(:notify_later)
        ActivityNotification::NotifyAllJob.perform_later(targets, notifiable, options)
      end

      # Generates notifications to one target.
      #
      # @example Notify to one user
      #   ActivityNotification::Notification.notify_to @comment.auther, @comment
      #
      # @param [Object] target Target to send notifications
      # @param [Object] notifiable Notifiable instance
      # @param [Hash] options Options for notifications
      # @option options [String]                  :key                      (notifiable.default_notification_key) Key of the notification
      # @option options [Object]                  :group                    (nil)                                 Group unit of the notifications
      # @option options [ActiveSupport::Duration] :group_expiry_delay       (nil)                                 Expiry period of a notification group
      # @option options [Object]                  :notifier                 (nil)                                 Notifier of the notifications
      # @option options [Hash]                    :parameters               ({})                                  Additional parameters of the notifications
      # @option options [Boolean]                 :notify_later             (false)                               Whether it generates notifications asynchronously
      # @option options [Boolean]                 :send_email               (true)                                Whether it sends notification email
      # @option options [Boolean]                 :send_later               (true)                                Whether it sends notification email asynchronously
      # @option options [Boolean]                 :publish_optional_targets (true)                                Whether it publishes notification to optional targets
      # @option options [Hash<String, Hash>]      :optional_targets         ({})                                  Options for optional targets, keys are optional target name (:amazon_sns or :slack etc) and values are options
      # @return [Notification] Generated notification instance
      def notify_to(target, notifiable, options = {})
        if options[:notify_later]
          notify_later_to(target, notifiable, options)
        else
          send_email               = options.has_key?(:send_email)               ? options[:send_email]               : true
          send_later               = options.has_key?(:send_later)               ? options[:send_later]               : true
          publish_optional_targets = options.has_key?(:publish_optional_targets) ? options[:publish_optional_targets] : true
          # Generate notification
          notification = generate_notification(target, notifiable, options)
          # Send notification email
          if notification.present? && send_email
            notification.send_notification_email({ send_later: send_later })
          end
          # Publish to optional targets
          if notification.present? && publish_optional_targets
            notification.publish_to_optional_targets(options[:optional_targets] || {})
          end
          # Return generated notification
          notification
        end
      end
      alias_method :notify_now_to, :notify_to

      # Generates notifications to one target later by ActiveJob queue.
      #
      # @example Notify to one user later
      #   ActivityNotification::Notification.notify_later_to @comment.auther, @comment
      #
      # @param [Object] target Target to send notifications
      # @param [Object] notifiable Notifiable instance
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
      def notify_later_to(target, notifiable, options = {})
        options.delete(:notify_later)
        ActivityNotification::NotifyToJob.perform_later(target, notifiable, options)
      end

      # Generates a notification
      # @param [Object] target Target to send notification
      # @param [Object] notifiable Notifiable instance
      # @param [Hash] options Options for notification
      # @option options [String]  :key        (notifiable.default_notification_key) Key of the notification
      # @option options [Object]  :group      (nil)                                 Group unit of the notifications
      # @option options [Object]  :notifier   (nil)                                 Notifier of the notifications
      # @option options [Hash]    :parameters ({})                                  Additional parameters of the notifications
      def generate_notification(target, notifiable, options = {})
        key = options[:key] || notifiable.default_notification_key
        if target.subscribes_to_notification?(key)
          # Store notification
          notification = store_notification(target, notifiable, key, options)
        end
      end

      # Opens all notifications of the target.
      #
      # @param [Object] target Target of the notifications to open
      # @param [Hash] options Options for opening notifications
      # @option options [DateTime] :opened_at              (Time.current) Time to set to opened_at of the notification record
      # @option options [String]   :filtered_by_type       (nil)          Notifiable type for filter
      # @option options [Object]   :filtered_by_group      (nil)          Group instance for filter
      # @option options [String]   :filtered_by_group_type (nil)          Group type for filter, valid with :filtered_by_group_id
      # @option options [String]   :filtered_by_group_id   (nil)          Group instance id for filter, valid with :filtered_by_group_type
      # @option options [String]   :filtered_by_key        (nil)          Key of the notification for filter
      # @option options [String]   :later_than             (nil)          ISO 8601 format time to filter notification index later than specified time
      # @option options [String]   :earlier_than           (nil)          ISO 8601 format time to filter notification index earlier than specified time
      # @return [Array<Notification>] Opened notification records
      def open_all_of(target, options = {})
        opened_at = options[:opened_at] || Time.current
        target_unopened_notifications = target.notifications.unopened_only.filtered_by_options(options)
        opened_notifications = target_unopened_notifications.to_a.map { |n| n.opened_at = opened_at; n }
        target_unopened_notifications.update_all(opened_at: opened_at)
        opened_notifications
      end

      # Returns if group member of the notifications exists.
      # This method is designed to be called from controllers or views to avoid N+1.
      #
      # @param [Array<Notificaion>, ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] notifications Array or database query of the notifications to test member exists
      # @return [Boolean] If group member of the notifications exists
      def group_member_exists?(notifications)
        notifications.present? and group_members_of_owner_ids_only(notifications.map(&:id)).exists?
      end

      # Sends batch notification email to the target.
      #
      # @param [Object]              target        Target of batch notification email
      # @param [Array<Notification>] notifications Target notifications to send batch notification email
      # @param [Hash]                options       Options for notification email
      # @option options [Boolean]        :send_later  (false)          If it sends notification email asynchronously
      # @option options [String, Symbol] :fallback    (:batch_default) Fallback template to use when MissingTemplate is raised
      # @option options [String]         :batch_key   (nil)            Key of the batch notification email, a key of the first notification will be used if not specified
      # @return [Mail::Message, ActionMailer::DeliveryJob|NilClass] Email message or its delivery job, return NilClass for wrong target
      def send_batch_notification_email(target, notifications, options = {})
        notifications.blank? and return
        batch_key = options[:batch_key] || notifications.first.key
        if target.batch_notification_email_allowed?(batch_key) &&
           target.subscribes_to_notification_email?(batch_key)
          send_later = options.has_key?(:send_later) ? options[:send_later] : true
          send_later ?
            @@notification_mailer.send_batch_notification_email(target, notifications, batch_key, options).deliver_later :
            @@notification_mailer.send_batch_notification_email(target, notifications, batch_key, options).deliver_now
        end
      end

      # Returns available options for kinds of notify methods.
      #
      # @return [Array<Notificaion>] Available options for kinds of notify methods
      def available_options
        [:key, :group, :group_expiry_delay, :notifier, :parameters, :send_email, :send_later, :pass_full_options].freeze
      end

      # Defines mailer class to send notification
      def set_notification_mailer
        @@notification_mailer = ActivityNotification.config.mailer.constantize
      end

      # Returns valid group owner within the expiration period
      #
      # @param [Object]                  target             Target to send notifications
      # @param [Object]                  notifiable         Notifiable instance
      # @param [String]                  key                Key of the notification
      # @param [Object]                  group              Group unit of the notifications
      # @param [ActiveSupport::Duration] group_expiry_delay Expiry period of a notification group
      # @return [Notificaion] Valid group owner within the expiration period
      def valid_group_owner(target, notifiable, key, group, group_expiry_delay)
        return nil if group.blank?
        # Bundle notification group by target, notifiable_type, group and key
        # Different notifiable.id can be made in a same group
        group_owner_notifications = filtered_by_target(target).filtered_by_type(notifiable.to_class_name).filtered_by_key(key)
                                   .filtered_by_group(group).group_owners_only.unopened_only
        group_expiry_delay.present? ?
          group_owner_notifications.within_expiration_only(group_expiry_delay).earliest :
          group_owner_notifications.earliest
      end

      # Stores notifications to datastore
      # @api private
      def store_notification(target, notifiable, key, options = {})
        target_type        = target.to_class_name
        group              = options[:group]              || notifiable.notification_group(target_type, key)
        group_expiry_delay = options[:group_expiry_delay] || notifiable.notification_group_expiry_delay(target_type, key)
        notifier           = options[:notifier]           || notifiable.notifier(target_type, key)
        parameters         = options[:parameters]         || {}
        parameters.merge!(options.except(*available_options))
        parameters.merge!(notifiable.notification_parameters(target_type, key))
        group_owner = valid_group_owner(target, notifiable, key, group, group_expiry_delay)

        notification = new({ target: target, notifiable: notifiable, key: key, group: group, parameters: parameters, notifier: notifier, group_owner: group_owner })
        notification.prepare_to_store.save
        notification.after_store
        notification
      end
    end

    # :nocov:
    # Returns prepared notification object to store
    # @return [Object] prepared notification object to store
    def prepare_to_store
      self
    end

    # Call after store action with stored notification
    def after_store
    end
    # :nocov:

    # Sends notification email to the target.
    #
    # @param [Hash] options Options for notification email
    # @option options [Boolean]        :send_later            If it sends notification email asynchronously
    # @option options [String, Symbol] :fallback   (:default) Fallback template to use when MissingTemplate is raised
    # @return [Mail::Message, ActionMailer::DeliveryJob] Email message or its delivery job
    def send_notification_email(options = {})
      if target.notification_email_allowed?(notifiable, key) &&
         notifiable.notification_email_allowed?(target, key) &&
         email_subscribed?
        send_later = options.has_key?(:send_later) ? options[:send_later] : true
        send_later ?
          @@notification_mailer.send_notification_email(self, options).deliver_later :
          @@notification_mailer.send_notification_email(self, options).deliver_now
      end
    end

    # Publishes notification to the optional targets.
    #
    # @param [Hash] options Options for optional targets
    # @return [Hash] Result of publishing to optional target
    def publish_to_optional_targets(options = {})
      notifiable.optional_targets(target.to_resources_name, key).map { |optional_target|
        optional_target_name = optional_target.to_optional_target_name
        if optional_target_subscribed?(optional_target_name)
          begin
            optional_target.notify(self, options[optional_target_name] || {})
            [optional_target_name, true]
          rescue => e
            Rails.logger.error(e)
            [optional_target_name, e]
          end
        else
          [optional_target_name, false]
        end
      }.to_h
    end

    # Opens the notification.
    #
    # @param [Hash] options Options for opening notifications
    # @option options [DateTime] :opened_at   (Time.current) Time to set to opened_at of the notification record
    # @option options [Boolean] :with_members (true)         If it opens notifications including group members
    # @return [Integer] Number of opened notification records
    def open!(options = {})
      opened? and return 0
      opened_at    = options[:opened_at] || Time.current
      with_members = options.has_key?(:with_members) ? options[:with_members] : true
      unopened_member_count = with_members ? group_members.unopened_only.count : 0
      group_members.update_all(opened_at: opened_at) if with_members
      update(opened_at: opened_at)
      unopened_member_count + 1
    end

    # Returns if the notification is unopened.
    #
    # @return [Boolean] If the notification is unopened
    def unopened?
      !opened?
    end

    # Returns if the notification is opened.
    #
    # @return [Boolean] If the notification is opened
    def opened?
      opened_at.present?
    end

    # Returns if the notification is group owner.
    #
    # @return [Boolean] If the notification is group owner
    def group_owner?
      !group_member?
    end

    # Returns if the notification is group member belonging to owner.
    #
    # @return [Boolean] If the notification is group member
    def group_member?
      group_owner_id.present?
    end

    # Returns if group member of the notification exists.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Boolean] If group member of the notification exists
    def group_member_exists?(limit = ActivityNotification.config.opened_index_limit)
      group_member_count(limit) > 0
    end

    # Returns if group member notifier except group owner notifier exists.
    # It always returns false if group owner notifier is blank.
    # It counts only the member notifier of the same type with group owner notifier.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Boolean] If group member of the notification exists
    def group_member_notifier_exists?(limit = ActivityNotification.config.opened_index_limit)
      group_member_notifier_count(limit) > 0
    end

    # Returns count of group members of the notification.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Integer] Count of group members of the notification
    def group_member_count(limit = ActivityNotification.config.opened_index_limit)
      meta_group_member_count(:opened_group_member_count, :unopened_group_member_count, limit)
    end

    # Returns count of group notifications including owner and members.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Integer] Count of group notifications including owner and members
    def group_notification_count(limit = ActivityNotification.config.opened_index_limit)
      group_member_count(limit) + 1
    end

    # Returns count of group member notifiers of the notification not including group owner notifier.
    # It always returns 0 if group owner notifier is blank.
    # It counts only the member notifier of the same type with group owner notifier.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Integer] Count of group member notifiers of the notification
    def group_member_notifier_count(limit = ActivityNotification.config.opened_index_limit)
      meta_group_member_count(:opened_group_member_notifier_count, :unopened_group_member_notifier_count, limit)
    end

    # Returns count of group member notifiers including group owner notifier.
    # It always returns 0 if group owner notifier is blank.
    # This method is designed to cache group by query result to avoid N+1 call.
    #
    # @param [Integer] limit Limit to query for opened notifications
    # @return [Integer] Count of group notifications including owner and members
    def group_notifier_count(limit = ActivityNotification.config.opened_index_limit)
      notification = group_member? && group_owner.present? ? group_owner : self
      notification.notifier.present? ? group_member_notifier_count(limit) + 1 : 0
    end

    # Returns the latest group member notification instance of this notification.
    # If this group owner has no group members, group owner instance self will be returned.
    #
    # @return [Notificaion] Notification instance of the latest group member notification
    def latest_group_member
      notification = group_member? && group_owner.present? ? group_owner : self
      notification.group_member_exists? ? notification.group_members.latest : self
    end

    # Remove from notification group and make a new group owner.
    #
    # @return [Notificaion] New group owner instance of the notification group
    def remove_from_group
      new_group_owner = group_members.earliest
      if new_group_owner.present?
        new_group_owner.update(group_owner_id: nil)
        group_members.update_all(group_owner_id: new_group_owner.id)
      end
      new_group_owner
    end

    # Returns notifiable_path to move after opening notification with notifiable.notifiable_path.
    #
    # @return [String] Notifiable path URL to move after opening notification
    def notifiable_path
      notifiable.blank? and raise ActivityNotification::NotifiableNotFoundError.new("Couldn't find associated notifiable (#{notifiable_type}) of #{self.class.name} with 'id'=#{id}")
      notifiable.notifiable_path(target_type, key)
    end

    # Returns printable notifiable model name to show in view or email.
    # @return [String] Printable notifiable model name
    def printable_notifiable_name
      notifiable.printable_notifiable_name(target, key)
    end

    # Returns if the target subscribes this notification.
    # @return [Boolean] If the target subscribes the notification
    def subscribed?
      target.subscribes_to_notification?(key)
    end

    # Returns if the target subscribes this notification email.
    # @return [Boolean] If the target subscribes the notification
    def email_subscribed?
      target.subscribes_to_notification_email?(key)
    end

    # Returns if the target subscribes this notification email.
    # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
    # @return [Boolean] If the target subscribes the specified optional target of the notification
    def optional_target_subscribed?(optional_target_name)
      target.subscribes_to_optional_target?(key, optional_target_name)
    end

    # Returns optional_targets of the notification from configured field or overridden method.
    # @return [Array<ActivityNotification::OptionalTarget::Base>] Array of optional target instances
    def optional_targets
      notifiable.optional_targets(target.to_resources_name, key)
    end

    # Returns optional_target names of the notification from configured field or overridden method.
    # @return [Array<Symbol>] Array of optional target names
    def optional_target_names
      notifiable.optional_target_names(target.to_resources_name, key)
    end

    protected

      # Returns count of various members of the notification.
      # This method is designed to cache group by query result to avoid N+1 call.
      # @api protected
      #
      # @param [Symbol] opened_member_count_method_name Method name to count members of unopened index
      # @param [Symbol] unopened_member_count_method_name Method name to count members of opened index
      # @param [Integer] limit Limit to query for opened notifications
      # @return [Integer] Count of various members of the notification
      def meta_group_member_count(opened_member_count_method_name, unopened_member_count_method_name, limit)
        notification = group_member? && group_owner.present? ? group_owner : self
        notification.opened? ?
          notification.send(opened_member_count_method_name, limit) :
          notification.send(unopened_member_count_method_name)
      end

  end
end