module ActivityNotification
  # Manages to add all required configurations to notifiable models.
  module ActsAsNotifiable
    extend ActiveSupport::Concern

    included do
      # Defines private clas methods
      private_class_method :add_tracked_callbacks, :add_tracked_callback, :add_destroy_dependency, :arrange_optional_targets_option
    end

    class_methods do
      # Adds required configurations to notifiable models.
      #
      # == Parameters:
      # * :targets
      #   * Targets to send notifications.
      #     It it set as ActiveRecord records or array of models.
      #     This is a only necessary option.
      #     If you do not specify this option, you have to override notification_targets
      #     or notification_[plural target type] (e.g. notification_users) method.
      # @example Notify to all users
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all
      #   end
      # @example Notify to author and users commented to the article, except comment owner self
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     belongs_to :user
      #     acts_as_notifiable :users,
      #       targets: ->(comment, key) {
      #         ([comment.article.user] + comment.article.commented_users.to_a - [comment.user]).uniq
      #       }
      #   end
      #
      # * :group
      #   * Group unit of notifications.
      #     Notifications will be bundled by this group (and target, notifiable_type, key).
      #     This parameter is a optional.
      # @example All *unopened* notifications to the same target will be grouped by `article`
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, group: :article
      #   end
      #
      # * :group_expiry_delay
      #   * Expiry period of a notification group.
      #     Notifications will be bundled within the group expiry period.
      #     This parameter is a optional.
      # @example All *unopened* notifications to the same target within 1 day will be grouped by `article`
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, group: :article, :group_expiry_delay: 1.day
      #   end
      #
      # * :notifier
      #   * Notifier of the notification.
      #     This will be stored as notifier with notification record.
      #     This parameter is a optional.
      # @example Set comment owner self as notifier
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     belongs_to :user
      #     acts_as_notifiable :users, targets: User.all, notifier: :user
      #   end
      #
      # * :parameters
      #   * Additional parameters of the notifications.
      #     This will be stored as parameters with notification record.
      #     You can use these additional parameters in your notification view or i18n text.
      #     This parameter is a optional.
      # @example Set constant values as additional parameter
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, parameters: { default_param: '1' }
      #   end
      # @example Set comment body as additional parameter
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, parameters: ->(comment, key) { body: comment.body }
      #   end
      #
      # * :email_allowed
      #   * Whether activity_notification sends notification email.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use notification email, email_allowed option must return true (not nil) in both of notifiable and target model.
      #     This can be also configured default option in initializer.
      # @example Enable email notification for this notifiable model
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, email_allowed: true
      #   end
      #
      # * :action_cable_allowed
      #   * Whether activity_notification publishes notifications to ActionCable channel.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use ActionCable for notifications, action_cable_allowed option must return true (not nil) in both of notifiable and target model.
      #     This can be also configured default option in initializer.
      # @example Enable notification ActionCable for this notifiable model
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, action_cable_allowed: true
      #   end
      #
      # * :notifiable_path
      #   * Path to redirect from open or move action of notification controller.
      #     You can also use this notifiable_path as notifiable link in notification view.
      #     This parameter is a optional since polymorphic_path is used as default value.
      # @example Redirect to parent article page from comment notifications
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, notifiable_path: :article_notifiable_path
      #
      #     def article_notifiable_path
      #       article_path(article)
      #     end
      #   end
      #
      # * :tracked
      #   * Adds required callbacks to generate notifications for creation and update of the notifiable model.
      #     Tracked notifications are disabled as default.
      #     When you set true as this :tracked option, default callbacks will be enabled for [:create, :update].
      #     You can use :only, :except and other notify options as hash for this option.
      #     Tracked notifications are generated synchronously as default configuration.
      #     You can use :notify_later option as notify options to make tracked notifications generated asynchronously.
      # @example Add all callbacks to generate notifications for creation and update
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, tracked: true
      #   end
      # @example Add callbacks to generate notifications for creation only
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, tracked: { only: [:create] }
      #   end
      # @example Add callbacks to generate notifications for creation (except update) only
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, tracked: { except: [:update], key: "comment.edited", send_later: false }
      #   end
      # @example Add callbacks to generate notifications asynchronously for creation only
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     belongs_to :article
      #     acts_as_notifiable :users, targets: User.all, tracked: { only: [:create], notify_later: true }
      #   end
      #
      # * :printable_name or :printable_notifiable_name
      #   * Printable notifiable name.
      #     This parameter is a optional since `ActivityNotification::Common.printable_name` is used as default value.
      #     :printable_name is the same option as :printable_notifiable_name
      # @example Define printable name with comment body
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, printable_name: ->(comment) { "comment \"#{comment.body}\"" }
      #   end
      #
      # * :dependent_notifications
      #   * Dependency for notifications to delete generated notifications with this notifiable.
      #     This option is used to configure generated_notifications_as_notifiable association.
      #     You can use :delete_all, :destroy, :restrict_with_error, :restrict_with_exception, :update_group_and_delete_all or :update_group_and_destroy for this option.
      #     When you use :update_group_and_delete_all or :update_group_and_destroy to this parameter, the oldest group member notification becomes a new group owner as `before_destroy` of this Notifiable.
      #     This parameter is effective for all target and is a optional since no dependent option is used as default.
      # @example Define :delete_all dependency to generated notifications
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     acts_as_notifiable :users, targets: User.all, dependent_notifications: :delete_all
      #   end
      #
      # * :optional_targets
      #   * Optional targets to integrate external notification serveces like Amazon SNS or Slack.
      #     You can use hash of optional target implementation class as key and initializing parameters as value for this parameter.
      #     When the hash parameter is passed, acts_as_notifiable will create new instance of optional target class and call initialize_target method with initializing parameters, then configure them as optional_targets for this notifiable and target.
      #     You can also use symbol of method name or lambda function which returns array of initialized optional target intstances.
      #     All optional target class must extends ActivityNotification::OptionalTarget::Base.
      #     This parameter is completely optional.
      # @example Define to integrate with Amazon SNS, Slack and your custom ConsoleOutput targets
      #   # app/models/comment.rb
      #   class Comment < ActiveRecord::Base
      #     require 'activity_notification/optional_targets/amazon_sns'
      #     require 'activity_notification/optional_targets/slack'
      #     require 'custom_optional_targets/console_output'
      #     acts_as_notifiable :admins, targets: Admin.all,
      #       optional_targets: {
      #         ActivityNotification::OptionalTarget::AmazonSNS => { topic_arn: '<Topin ARN of yours>' },
      #         ActivityNotification::OptionalTarget::Slack  => {
      #           webhook_url: '<Slack Webhook URL>',
      #           slack_name: :slack_name, channel: 'activity_notification', username: 'ActivityNotification', icon_emoji: ":ghost:"
      #         },
      #         CustomOptionalTarget::ConsoleOutput => {}
      #       }
      #   end
      #
      # @param [Symbol] target_type Type of notification target as symbol
      # @param [Hash] options Options for notifiable model configuration
      # @option options [Symbol, Proc, Array]   :targets                 (nil)                    Targets to send notifications
      # @option options [Symbol, Proc, Object]  :group                   (nil)                    Group unit of the notifications
      # @option options [Symbol, Proc, Object]  :group_expiry_delay      (nil)                    Expiry period of a notification group
      # @option options [Symbol, Proc, Object]  :notifier                (nil)                    Notifier of the notifications
      # @option options [Symbol, Proc, Hash]    :parameters              ({})                     Additional parameters of the notifications
      # @option options [Symbol, Proc, Boolean] :email_allowed           (ActivityNotification.config.email_enabled) Whether activity_notification sends notification email
      # @option options [Symbol, Proc, Boolean] :action_cable_allowed    (ActivityNotification.config.action_cable_enabled) Whether activity_notification publishes WebSocket using ActionCable
      # @option options [Symbol, Proc, String]  :notifiable_path         (polymorphic_path(self)) Path to redirect from open or move action of notification controller
      # @option options [Boolean, Hash]         :tracked                 (nil)                    Flag or parameters for automatic tracked notifications
      # @option options [Symbol, Proc, String]  :printable_name          (ActivityNotification::Common.printable_name) Printable notifiable name
      # @option options [Symbol, Proc]          :dependent_notifications (nil)                    Dependency for notifications to delete generated notifications with this notifiable, [:delete_all, :destroy, :restrict_with_error, :restrict_with_exception, :update_group_and_delete_all, :update_group_and_destroy] are available
      # @option options [Hash<Class, Hash>]     :optional_targets        (nil)                    Optional target configurations with hash of `OptionalTarget` implementation class as key and initializing option parameter as value
      # @return [Hash] Configured parameters as notifiable model
      def acts_as_notifiable(target_type, options = {})
        include Notifiable
        configured_params = {}

        if options[:tracked].present?
          configured_params.update(add_tracked_callbacks(target_type, options[:tracked].is_a?(Hash) ? options[:tracked] : {}))
        end

        if available_dependent_notifications_options.include? options[:dependent_notifications]
          configured_params.update(add_destroy_dependency(target_type, options[:dependent_notifications]))
        end

        if options[:optional_targets].is_a?(Hash)
          options[:optional_targets] = arrange_optional_targets_option(options[:optional_targets])
        end

        options[:printable_notifiable_name] ||= options.delete(:printable_name)
        configured_params
          .merge set_acts_as_parameters_for_target(target_type, [:targets, :group, :group_expiry_delay, :parameters, :email_allowed, :action_cable_allowed], options, "notification_")
          .merge set_acts_as_parameters_for_target(target_type, [:notifier, :notifiable_path, :printable_notifiable_name, :optional_targets], options)
      end

      # Returns array of available notifiable options in acts_as_notifiable.
      # @return [Array<Symbol>] Array of available notifiable options
      def available_notifiable_options
        [ :targets,
          :group,
          :group_expiry_delay,
          :notifier,
          :parameters,
          :email_allowed,
          :action_cable_allowed,
          :notifiable_path,
          :printable_notifiable_name, :printable_name,
          :dependent_notifications,
          :optional_targets
        ].freeze
      end

      # Returns array of available notifiable options in acts_as_notifiable.
      # @return [Array<Symbol>] Array of available notifiable options
      def available_dependent_notifications_options
        [ :delete_all,
          :destroy,
          :restrict_with_error,
          :restrict_with_exception,
          :update_group_and_delete_all,
          :update_group_and_destroy
        ].freeze
      end

      # Adds tracked callbacks.
      # @param [Symbol] target_type    Type of notification target as symbol
      # @param [Hash]   tracked_option Specified :tracked option
      # @return [Hash<Symbol, Symbol>] Configured tracked callbacks options
      def add_tracked_callbacks(target_type, tracked_option = {})
        tracked_callbacks = [:create, :update]
        if tracked_option[:except]
          tracked_callbacks -= tracked_option.delete(:except)
        elsif tracked_option[:only]
          tracked_callbacks &= tracked_option.delete(:only)
        end
        if tracked_option.has_key?(:key)
          add_tracked_callback(tracked_callbacks, :create, ->{ notify target_type, tracked_option })
          add_tracked_callback(tracked_callbacks, :update, ->{ notify target_type, tracked_option })
        else
          add_tracked_callback(tracked_callbacks, :create, ->{ notify target_type, tracked_option.merge(key: notification_key_for_tracked_creation) })
          add_tracked_callback(tracked_callbacks, :update, ->{ notify target_type, tracked_option.merge(key: notification_key_for_tracked_update) })
        end
        { tracked: tracked_callbacks }
      end

      # Adds tracked callback.
      # @param [Array<Symbol>] tracked_callbacks Array of tracked callbacks (Array of [:create or :update])
      # @param [Symbol]        tracked_action    Tracked action (:create or :update)
      # @param [Proc]          tracked_proc      Proc or lambda function to execute
      def add_tracked_callback(tracked_callbacks, tracked_action, tracked_proc)
        return unless tracked_callbacks.include? tracked_action

        # FIXME: Avoid Rails issue that after commit callbacks on update does not triggered when optimistic locking is enabled
        # See the followings:
        #   https://github.com/rails/rails/issues/30779
        #   https://github.com/rails/rails/pull/32167

        # :only-rails5-plus#only-rails-without-callback-issue:
        # :only-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-without-callback-issue:
        # :except-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        if !(Gem::Version.new("5.1.6") <= Rails.gem_version && Rails.gem_version < Gem::Version.new("5.2.2")) && respond_to?(:after_commit)
          after_commit tracked_proc, on: tracked_action
        # :only-rails5-plus#only-rails-without-callback-issue:
        # :only-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-without-callback-issue:
        # :except-rails5-plus#only-rails-without-callback-issue#except-dynamoid:

        # :only-rails5-plus#only-rails-with-callback-issue:
        # :only-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-with-callback-issue:
        # :except-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        else
          case tracked_action
          when :create
            after_create tracked_proc
          when :update
            after_update tracked_proc
          end
        end
        # :only-rails5-plus#only-rails-with-callback-issue:
        # :only-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-with-callback-issue:
        # :except-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
      end

      # Adds destroy dependency.
      # @param [Symbol] target_type                    Type of notification target as symbol
      # @param [Symbol] dependent_notifications_option Specified :dependent_notifications option
      # @return [Hash<Symbol, Symbol>] Configured dependency options
      def add_destroy_dependency(target_type, dependent_notifications_option)
        case dependent_notifications_option
        when :delete_all, :destroy, :restrict_with_error, :restrict_with_exception
          before_destroy -> { destroy_generated_notifications_with_dependency(dependent_notifications_option, target_type) }
        when :update_group_and_delete_all
          before_destroy -> { destroy_generated_notifications_with_dependency(:delete_all, target_type, true) }
        when :update_group_and_destroy
          before_destroy -> { destroy_generated_notifications_with_dependency(:destroy, target_type, true) }
        end
        { dependent_notifications: dependent_notifications_option }
      end

      # Arrange optional targets option.
      # @param [Symbol] optional_targets_option Specified :optional_targets option
      # @return [Hash<ActivityNotification::OptionalTarget::Base, Hash>] Arranged optional targets options
      def arrange_optional_targets_option(optional_targets_option)
        optional_targets_option.map { |target_class, target_options|
          optional_target = target_class.new(target_options)
          unless optional_target.kind_of?(ActivityNotification::OptionalTarget::Base)
            raise TypeError, "#{optional_target.class.name} for an optional target is not a kind of ActivityNotification::OptionalTarget::Base"
          end
          optional_target
        }
      end
    end
  end
end
