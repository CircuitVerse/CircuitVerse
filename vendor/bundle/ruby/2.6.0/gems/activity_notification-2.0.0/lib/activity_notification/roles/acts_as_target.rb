module ActivityNotification
  # Manages to add all required configurations to target models of notification.
  module ActsAsTarget
    extend ActiveSupport::Concern

    class_methods do
      # Adds required configurations to notifiable models.
      #
      # == Parameters:
      # * :email
      #   * Email address to send notification email.
      #     This is a necessary option when you enables email notification.
      # @example Simply use :email field
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     validates :email, presence: true
      #     acts_as_target email: :email
      #   end
      #
      # * :email_allowed
      #   * Whether activity_notification sends notification email to this target.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use notification email, email_allowed option must return true (not nil) in both of notifiable and target model.
      #     This can be also configured default option in initializer.
      # @example Always enable email notification for this target
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target email: :email, email_allowed: true
      #   end
      # @example Use confirmed_at of devise field to decide whether activity_notification sends notification email to this user
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target email: :email, email_allowed: :confirmed_at
      #   end
      #
      # * :batch_email_allowed
      #   * Whether activity_notification sends batch notification email to this target.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use batch notification email, both of batch_email_allowed and subscription_allowed options must return true (not nil) in target model.
      #     This can be also configured default option in initializer.
      # @example Always enable batch email notification for this target
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target email: :email, batch_email_allowed: true
      #   end
      # @example Use confirmed_at of devise field to decide whether activity_notification sends batch notification email to this user
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target email: :email, batch_email_allowed: :confirmed_at
      #   end
      #
      # * :subscription_allowed
      #   * Whether activity_notification manages subscriptions of this target.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     This can be also configured default option in initializer.
      # @example Subscribe notifications for this target
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target subscription_allowed: true
      #   end
      #
      # * :action_cable_allowed
      #   * Whether activity_notification publishes WebSocket notifications using ActionCable to this target.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use ActionCable for notifications, action_cable_enabled option must return true (not nil) in both of notifiable and target model.
      #     This can be also configured default option in initializer.
      # @example Enable notification ActionCable for this target
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target action_cable_allowed: true
      #   end
      #
      # * :action_cable_with_devise
      #   * Whether activity_notification publishes WebSocket notifications using ActionCable only to authenticated target with Devise.
      #     Specified method or symbol is expected to return true (not nil) or false (nil).
      #     This parameter is a optional since default value is false.
      #     To use ActionCable for notifications, also action_cable_enabled option must return true (not nil) in the target model.
      # @example Enable notification ActionCable for this target
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target action_cable_allowed: true, action_cable_with_devise* true
      #   end
      #
      # * :devise_resource
      #   * Integrated resource with devise authentication.
      #     This parameter is a optional since `self` is used as default value.
      #     You also have to configure routing for devise in routes.rb
      # @example No :devise_resource is needed when notification target is the same as authenticated resource
      #   # config/routes.rb
      #   devise_for :users
      #   notify_to :users
      #
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     devise :database_authenticatable, :registerable, :confirmable
      #     acts_as_target email: :email, email_allowed: :confirmed_at
      #   end
      #
      # @example Send Admin model and use associated User model with devise authentication
      #   # config/routes.rb
      #   devise_for :users
      #   notify_to :admins, with_devise: :users
      #
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     devise :database_authenticatable, :registerable, :confirmable
      #   end
      #
      #   # app/models/admin.rb
      #   class Admin < ActiveRecord::Base
      #     belongs_to :user
      #     validates :user, presence: true
      #     acts_as_notification_target email: :email,
      #       email_allowed: ->(admin, key) { admin.user.confirmed_at.present? },
      #       devise_resource: :user
      #   end
      #
      # * :current_devise_target
      #   * Current authenticated target by devise authentication.
      #     This parameter is a optional since `current_<devise_resource_name>` is used as default value.
      #     In addition, this parameter is only needed when :devise_default_route in your route.rb is enabled.
      #     You also have to configure routing for devise in routes.rb
      # @example No :current_devise_target is needed when notification target is the same as authenticated resource
      #   # config/routes.rb
      #   devise_for :users
      #   notify_to :users
      #
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     devise :database_authenticatable, :registerable, :confirmable
      #     acts_as_target email: :email, email_allowed: :confirmed_at
      #   end
      #
      # @example Send Admin model and use associated User model with devise authentication
      #   # config/routes.rb
      #   devise_for :users
      #   notify_to :admins, with_devise: :users
      #
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     devise :database_authenticatable, :registerable, :confirmable
      #   end
      #
      #   # app/models/admin.rb
      #   class Admin < ActiveRecord::Base
      #     belongs_to :user
      #     validates :user, presence: true
      #     acts_as_notification_target email: :email,
      #       email_allowed: ->(admin, key) { admin.user.confirmed_at.present? },
      #       devise_resource: :user,
      #       current_devise_target: ->(current_user) { current_user.admin }
      #   end
      #
      # * :printable_name or :printable_notification_target_name
      #   * Printable notification target name.
      #     This parameter is a optional since `ActivityNotification::Common.printable_name` is used as default value.
      #     :printable_name is the same option as :printable_notification_target_name
      # @example Define printable name with user name of name field
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #     acts_as_target printable_name: :name
      #   end
      #
      # @example Define printable name with associated user name
      #   # app/models/admin.rb
      #   class Admin < ActiveRecord::Base
      #     acts_as_target printable_notification_target_name: ->(admin) { "admin (#{admin.user.name})" }
      #   end
      #
      # @param [Hash] options Options for notifiable model configuration
      # @option options [Symbol, Proc, String]  :email                    (nil)                                              Email address to send notification email
      # @option options [Symbol, Proc, Boolean] :email_allowed            (ActivityNotification.config.email_enabled)        Whether activity_notification sends notification email to this target
      # @option options [Symbol, Proc, Boolean] :batch_email_allowed      (ActivityNotification.config.email_enabled)        Whether activity_notification sends batch notification email to this target
      # @option options [Symbol, Proc, Boolean] :subscription_allowed     (ActivityNotification.config.subscription_enabled) Whether activity_notification manages subscriptions of this target
      # @option options [Symbol, Proc, Boolean] :action_cable_allowed     (ActivityNotification.config.action_cable_enabled) Whether activity_notification publishes WebSocket notifications using ActionCable to this target
      # @option options [Symbol, Proc, Boolean] :action_cable_with_devise (false)                                            Whether activity_notification publishes WebSocket notifications using ActionCable only to authenticated target with Devise
      # @option options [Symbol, Proc, Object]  :devise_resource          (->(model) { model })                              Integrated resource with devise authentication
      # @option options [Symbol, Proc, Object]  :current_devise_target    (->(current_resource) { current_resource })        Current authenticated target by devise authentication
      # @option options [Symbol, Proc, String]  :printable_name           (ActivityNotification::Common.printable_name)      Printable notification target name
      # @return [Hash] Configured parameters as target model
      def acts_as_target(options = {})
        include Target

        options[:printable_notification_target_name] ||= options.delete(:printable_name)
        options[:batch_notification_email_allowed] ||= options.delete(:batch_email_allowed)
        acts_as_params = set_acts_as_parameters([:email, :email_allowed, :subscription_allowed, :action_cable_allowed, :action_cable_with_devise, :devise_resource, :current_devise_target], options, "notification_")
                           .merge set_acts_as_parameters([:batch_notification_email_allowed, :printable_notification_target_name], options)
        include Subscriber if subscription_enabled?
        acts_as_params
      end
      alias_method :acts_as_notification_target, :acts_as_target

      # Returns array of available target options in acts_as_target.
      # @return [Array<Symbol>] Array of available target options
      def available_target_options
        [:email, :email_allowed, :batch_email_allowed, :subscription_allowed, :action_cable_enabled, :action_cable_with_devise, :devise_resource, :printable_notification_target_name, :printable_name].freeze
      end
    end
  end
end
