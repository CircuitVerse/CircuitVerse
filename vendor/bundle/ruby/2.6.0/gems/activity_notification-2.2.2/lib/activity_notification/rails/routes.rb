require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/slice"

module ActionDispatch::Routing
  # Extended ActionDispatch::Routing::Mapper implementation to add routing method of ActivityNotification.
  class Mapper
    include ActivityNotification::PolymorphicHelpers

    # Includes notify_to method for routes, which is responsible to generate all necessary routes for notifications of activity_notification.
    #
    # When you have an User model configured as a target (e.g. defined acts_as_target),
    # you can create as follows in your routes:
    #   notify_to :users
    # This method creates the needed routes:
    #   # Notification routes
    #     user_notifications          GET    /users/:user_id/notifications(.:format)
    #       { controller:"activity_notification/notifications", action:"index", target_type:"users" }
    #     user_notification           GET    /users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications", action:"show", target_type:"users" }
    #     user_notification           DELETE /users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications", action:"destroy", target_type:"users" }
    #     open_all_user_notifications POST   /users/:user_id/notifications/open_all(.:format)
    #       { controller:"activity_notification/notifications", action:"open_all", target_type:"users" }
    #     move_user_notification      GET    /users/:user_id/notifications/:id/move(.:format)
    #       { controller:"activity_notification/notifications", action:"move", target_type:"users" }
    #     open_user_notification      PUT    /users/:user_id/notifications/:id/open(.:format)
    #       { controller:"activity_notification/notifications", action:"open", target_type:"users" }
    #
    # You can also configure notification routes with scope like this:
    #   scope :myscope, as: :myscope do
    #     notify_to :users, routing_scope: :myscope
    #   end
    # This routing_scope option creates the needed routes with specified scope like this:
    #   # Notification routes
    #     myscope_user_notifications          GET    /myscope/users/:user_id/notifications(.:format)
    #       { controller:"activity_notification/notifications", action:"index", target_type:"users", routing_scope: :myscope }
    #     myscope_user_notification           GET    /myscope/users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications", action:"show", target_type:"users", routing_scope: :myscope }
    #     myscope_user_notification           DELETE /myscope/users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications", action:"destroy", target_type:"users", routing_scope: :myscope }
    #     open_all_myscope_user_notifications POST   /myscope/users/:user_id/notifications/open_all(.:format)
    #       { controller:"activity_notification/notifications", action:"open_all", target_type:"users", routing_scope: :myscope }
    #     move_myscope_user_notification      GET    /myscope/users/:user_id/notifications/:id/move(.:format)
    #       { controller:"activity_notification/notifications", action:"move", target_type:"users", routing_scope: :myscope }
    #     open_myscope_user_notification      PUT    /myscope/users/:user_id/notifications/:id/open(.:format)
    #       { controller:"activity_notification/notifications", action:"open", target_type:"users", routing_scope: :myscope }
    #
    # When you use devise authentication and you want make notification targets assciated with devise,
    # you can create as follows in your routes:
    #   notify_to :users, with_devise: :users
    # This with_devise option creates the needed routes assciated with devise authentication:
    #   # Notification with devise routes
    #     user_notifications          GET    /users/:user_id/notifications(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"index", target_type:"users", devise_type:"users" }
    #     user_notification           GET    /users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"show", target_type:"users", devise_type:"users" }
    #     user_notification           DELETE /users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"destroy", target_type:"users", devise_type:"users" }
    #     open_all_user_notifications POST   /users/:user_id/notifications/open_all(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"open_all", target_type:"users", devise_type:"users" }
    #     move_user_notification      GET    /users/:user_id/notifications/:id/move(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"move", target_type:"users", devise_type:"users" }
    #     open_user_notification      PUT    /users/:user_id/notifications/:id/open(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"open", target_type:"users", devise_type:"users" }
    #
    # When you use with_devise option and you want to make simple default routes as follows, you can use devise_default_routes option:
    #   notify_to :users, with_devise: :users, devise_default_routes: true
    # These with_devise and devise_default_routes options create the needed routes assciated with authenticated devise resource as the default target
    #   # Notification with default devise routes
    #     user_notifications          GET    /notifications(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"index", target_type:"users", devise_type:"users" }
    #     user_notification           GET    /notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"show", target_type:"users", devise_type:"users" }
    #     user_notification           DELETE /notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"destroy", target_type:"users", devise_type:"users" }
    #     open_all_user_notifications POST   /notifications/open_all(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"open_all", target_type:"users", devise_type:"users" }
    #     move_user_notification      GET    /notifications/:id/move(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"move", target_type:"users", devise_type:"users" }
    #     open_user_notification      PUT    /notifications/:id/open(.:format)
    #       { controller:"activity_notification/notifications_with_devise", action:"open", target_type:"users", devise_type:"users" }
    #
    # When you use activity_notification controllers as REST API mode,
    # you can create as follows in your routes:
    #   scope :api do
    #     scope :"v2" do
    #       notify_to :users, api_mode: true
    #     end
    #   end
    # This api_mode option creates the needed routes as REST API:
    #   # Notification as API mode routes
    #     GET    /api/v2/users/:user_id/notifications(.:format)
    #       { controller:"activity_notification/notifications_api", action:"index", target_type:"users" }
    #     GET    /api/v2/users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_api", action:"show", target_type:"users" }
    #     DELETE /api/v2/users/:user_id/notifications/:id(.:format)
    #       { controller:"activity_notification/notifications_api", action:"destroy", target_type:"users" }
    #     POST   /api/v2/users/:user_id/notifications/open_all(.:format)
    #       { controller:"activity_notification/notifications_api", action:"open_all", target_type:"users" }
    #     GET    /api/v2/users/:user_id/notifications/:id/move(.:format)
    #       { controller:"activity_notification/notifications_api", action:"move", target_type:"users" }
    #     PUT    /api/v2/users/:user_id/notifications/:id/open(.:format)
    #       { controller:"activity_notification/notifications_api", action:"open", target_type:"users" }
    #
    # When you would like to define subscription management paths with notification paths,
    # you can create as follows in your routes:
    #   notify_to :users, with_subscription: true
    # or you can also set options for subscription path:
    #   notify_to :users, with_subscription: { except: [:index] }
    # If you configure this :with_subscription option with :with_devise option, with_subscription paths are also automatically configured with devise authentication as the same as notifications
    #   notify_to :users, with_devise: :users, with_subscription: true
    #
    # @example Define notify_to in config/routes.rb
    #   notify_to :users
    # @example Define notify_to with options
    #   notify_to :users, only: [:open, :open_all, :move]
    # @example Integrated with Devise authentication
    #   notify_to :users, with_devise: :users
    # @example Define notification paths including subscription paths
    #   notify_to :users, with_subscription: true
    # @example Integrated with Devise authentication as simple default routes including subscription management
    #   notify_to :users, with_devise: :users, devise_default_routes: true, with_subscription: true
    # @example Integrated with Devise authentication as simple default routes with scope including subscription management
    #   scope :myscope, as: :myscope do
    #     notify_to :myscope, with_devise: :users, devise_default_routes: true, with_subscription: true, routing_scope: :myscope
    #   end
    # @example Define notification paths as API mode including subscription paths
    #   scope :api do
    #     scope :"v2" do
    #       notify_to :users, api_mode: true, with_subscription: true
    #     end
    #   end
    #
    # @overload notify_to(*resources, *options)
    #   @param          [Symbol]       resources Resources to notify
    #   @option options [String]       :routing_scope         (nil)            Routing scope for notification routes
    #   @option options [Symbol]       :with_devise           (false)          Devise resources name for devise integration. Devise integration will be enabled by this option.
    #   @option options [Boolean]      :devise_default_routes (false)          Whether you will create routes as device default routes assciated with authenticated devise resource as the default target
    #   @option options [Boolean]      :api_mode              (false)          Whether you will use activity_notification controllers as REST API mode
    #   @option options [Hash|Boolean] :with_subscription     (false)          Subscription path options to define subscription management paths with notification paths. Calls subscribed_by routing when truthy value is passed as this option.
    #   @option options [String]       :model                 (:notifications) Model name of notifications
    #   @option options [String]       :controller            ("activity_notification/notifications" | activity_notification/notifications_with_devise") :controller option as resources routing
    #   @option options [Symbol]       :as                    (nil)            :as option as resources routing
    #   @option options [Array]        :only                  (nil)            :only option as resources routing
    #   @option options [Array]        :except                (nil)            :except option as resources routing
    # @return [ActionDispatch::Routing::Mapper] Routing mapper instance
    def notify_to(*resources)
      options = create_options(:notifications, resources.extract_options!, [:new, :create, :edit, :update])

      resources.each do |target|
        options[:defaults] = { target_type: target.to_s }.merge(options[:devise_defaults])
        resources_options = options.select { |key, _| [:api_mode, :with_devise, :devise_default_routes, :with_subscription, :subscription_option, :model, :devise_defaults].exclude? key }
        if options[:with_devise].present? && options[:devise_default_routes].present?
          create_notification_routes options, resources_options
        else
          self.resources target, only: :none do
            create_notification_routes options, resources_options
          end
        end

        if options[:with_subscription].present? && target.to_s.to_model_class.subscription_enabled?
          subscribed_by target, options[:subscription_option]
        end
      end

      self
    end

    # Includes subscribed_by method for routes, which is responsible to generate all necessary routes for subscriptions of activity_notification.
    #
    # When you have an User model configured as a target (e.g. defined acts_as_target),
    # you can create as follows in your routes:
    #   subscribed_by :users
    # This method creates the needed routes:
    #   # Subscription routes
    #     user_subscriptions                                GET    /users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions", action:"index", target_type:"users" }
    #     find_user_subscriptions                           GET    /users/:user_id/subscriptions/find(.:format)
    #       { controller:"activity_notification/subscriptions", action:"find", target_type:"users" }
    #     user_subscription                                 GET    /users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions", action:"show", target_type:"users" }
    #                                                       PUT    /users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions", action:"create", target_type:"users" }
    #                                                       DELETE /users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions", action:"destroy", target_type:"users" }
    #     subscribe_user_subscription                       PUT    /users/:user_id/subscriptions/:id/subscribe(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe", target_type:"users" }
    #     unsubscribe_user_subscription                     PUT    /users/:user_id/subscriptions/:id/unsubscribe(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe", target_type:"users" }
    #     subscribe_to_email_user_subscription              PUT    /users/:user_id/subscriptions/:id/subscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe_to_email", target_type:"users" }
    #     unsubscribe_to_email_user_subscription            PUT    /users/:user_id/subscriptions/:id/unsubscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe_to_email", target_type:"users" }
    #     subscribe_to_optional_target_user_subscription    PUT    /users/:user_id/subscriptions/:id/subscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe_to_optional_target", target_type:"users" }
    #     unsubscribe_to_optional_target_user_subscription  PUT    /users/:user_id/subscriptions/:id/unsubscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe_to_optional_target", target_type:"users" }
    #
    # You can also configure notification routes with scope like this:
    #   scope :myscope, as: :myscope do
    #     subscribed_by :users, routing_scope: :myscope
    #   end
    # This routing_scope option creates the needed routes with specified scope like this:
    #   # Subscription routes
    #     myscope_user_subscriptions                                GET    /myscope/users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions", action:"index", target_type:"users", routing_scope: :myscope }
    #     find_myscope_user_subscriptions                           GET    /myscope/users/:user_id/subscriptions/find(.:format)
    #       { controller:"activity_notification/subscriptions", action:"find", target_type:"users", routing_scope: :myscope }
    #     myscope_user_subscription                                 GET    /myscope/users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions", action:"show", target_type:"users", routing_scope: :myscope }
    #                                                               PUT    /myscope/users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions", action:"create", target_type:"users", routing_scope: :myscope }
    #                                                               DELETE /myscope/users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions", action:"destroy", target_type:"users", routing_scope: :myscope }
    #     subscribe_myscope_user_subscription                       PUT    /myscope/users/:user_id/subscriptions/:id/subscribe(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe", target_type:"users", routing_scope: :myscope }
    #     unsubscribe_myscope_user_subscription                     PUT    /myscope/users/:user_id/subscriptions/:id/unsubscribe(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe", target_type:"users", routing_scope: :myscope }
    #     subscribe_to_email_myscope_user_subscription              PUT    /myscope/users/:user_id/subscriptions/:id/subscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe_to_email", target_type:"users", routing_scope: :myscope }
    #     unsubscribe_to_email_myscope_user_subscription            PUT    /myscope/users/:user_id/subscriptions/:id/unsubscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe_to_email", target_type:"users", routing_scope: :myscope }
    #     subscribe_to_optional_target_myscope_user_subscription    PUT    /myscope/users/:user_id/subscriptions/:id/subscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions", action:"subscribe_to_optional_target", target_type:"users", routing_scope: :myscope }
    #     unsubscribe_to_optional_target_myscope_user_subscription  PUT    /myscope/users/:user_id/subscriptions/:id/unsubscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions", action:"unsubscribe_to_optional_target", target_type:"users", routing_scope: :myscope }
    #
    # When you use devise authentication and you want make subscription targets assciated with devise,
    # you can create as follows in your routes:
    #   subscribed_by :users, with_devise: :users
    # This with_devise option creates the needed routes assciated with devise authentication:
    #   # Subscription with devise routes
    #     user_subscriptions                                GET    /users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"index", target_type:"users", devise_type:"users" }
    #     find_user_subscriptions                           GET    /users/:user_id/subscriptions/find(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"find", target_type:"users", devise_type:"users" }
    #     user_subscription                                 GET    /users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"show", target_type:"users", devise_type:"users" }
    #                                                       PUT    /users/:user_id/subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"create", target_type:"users", devise_type:"users" }
    #                                                       DELETE /users/:user_id/subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"destroy", target_type:"users", devise_type:"users" }
    #     subscribe_user_subscription                       PUT    /users/:user_id/subscriptions/:id/subscribe(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe", target_type:"users", devise_type:"users" }
    #     unsubscribe_user_subscription                     PUT    /users/:user_id/subscriptions/:id/unsubscribe(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe", target_type:"users", devise_type:"users" }
    #     subscribe_to_email_user_subscription              PUT    /users/:user_id/subscriptions/:id/subscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe_to_email", target_type:"users", devise_type:"users" }
    #     unsubscribe_to_email_user_subscription            PUT    /users/:user_id/subscriptions/:id/unsubscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe_to_email", target_type:"users", devise_type:"users" }
    #     subscribe_to_optional_target_user_subscription    PUT    /users/:user_id/subscriptions/:id/subscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe_to_optional_target", target_type:"users", devise_type:"users" }
    #     unsubscribe_to_optional_target_user_subscription  PUT    /users/:user_id/subscriptions/:id/unsubscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe_to_optional_target", target_type:"users", devise_type:"users" }
    #
    # When you use with_devise option and you want to make simple default routes as follows, you can use devise_default_routes option:
    #   subscribed_by :users, with_devise: :users, devise_default_routes: true
    # These with_devise and devise_default_routes options create the needed routes assciated with authenticated devise resource as the default target
    #   # Subscription with devise routes
    #     user_subscriptions                                GET    /subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"index", target_type:"users", devise_type:"users" }
    #     find_user_subscriptions                           GET    /subscriptions/find(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"find", target_type:"users", devise_type:"users" }
    #     user_subscription                                 GET    /subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"show", target_type:"users", devise_type:"users" }
    #                                                       PUT    /subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"create", target_type:"users", devise_type:"users" }
    #                                                       DELETE /subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"destroy", target_type:"users", devise_type:"users" }
    #     subscribe_user_subscription                       PUT    /subscriptions/:id/subscribe(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe", target_type:"users", devise_type:"users" }
    #     unsubscribe_user_subscription                     PUT    /subscriptions/:id/unsubscribe(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe", target_type:"users", devise_type:"users" }
    #     subscribe_to_email_user_subscription              PUT    /subscriptions/:id/subscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe_to_email", target_type:"users", devise_type:"users" }
    #     unsubscribe_to_email_user_subscription            PUT    /subscriptions/:id/unsubscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe_to_email", target_type:"users", devise_type:"users" }
    #     subscribe_to_optional_target_user_subscription    PUT    /subscriptions/:id/subscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"subscribe_to_optional_target", target_type:"users", devise_type:"users" }
    #     unsubscribe_to_optional_target_user_subscription  PUT    /subscriptions/:id/unsubscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_with_devise", action:"unsubscribe_to_optional_target", target_type:"users", devise_type:"users" }
    #
    # When you use activity_notification controllers as REST API mode,
    # you can create as follows in your routes:
    #   scope :api do
    #     scope :"v2" do
    #       subscribed_by :users, api_mode: true
    #     end
    #   end
    # This api_mode option creates the needed routes as REST API:
    #   # Subscription as API mode routes
    #     GET    /subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"index", target_type:"users" }
    #     GET    /subscriptions/find(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"find", target_type:"users" }
    #     GET    /subscriptions/optional_target_names(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"optional_target_names", target_type:"users" }
    #     GET    /subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"show", target_type:"users" }
    #     PUT    /subscriptions(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"create", target_type:"users" }
    #     DELETE /subscriptions/:id(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"destroy", target_type:"users" }
    #     PUT    /subscriptions/:id/subscribe(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"subscribe", target_type:"users" }
    #     PUT    /subscriptions/:id/unsubscribe(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"unsubscribe", target_type:"users" }
    #     PUT    /subscriptions/:id/subscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"subscribe_to_email", target_type:"users" }
    #     PUT    /subscriptions/:id/unsubscribe_to_email(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"unsubscribe_to_email", target_type:"users" }
    #     PUT    /subscriptions/:id/subscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"subscribe_to_optional_target", target_type:"users" }
    #     PUT    /subscriptions/:id/unsubscribe_to_optional_target(.:format)
    #       { controller:"activity_notification/subscriptions_api", action:"unsubscribe_to_optional_target", target_type:"users" }
    #
    # @example Define subscribed_by in config/routes.rb
    #   subscribed_by :users
    # @example Define subscribed_by with options
    #   subscribed_by :users, except: [:index, :show]
    # @example Integrated with Devise authentication
    #   subscribed_by :users, with_devise: :users
    # @example Define subscription paths as API mode
    #   scope :api do
    #     scope :"v2" do
    #       subscribed_by :users, api_mode: true
    #     end
    #   end
    #
    # @overload subscribed_by(*resources, *options)
    #   @param          [Symbol]       resources Resources to notify
    #   @option options [String]       :routing_scope         (nil)            Routing scope for subscription routes
    #   @option options [Symbol]       :with_devise           (false)          Devise resources name for devise integration. Devise integration will be enabled by this option.
    #   @option options [Boolean]      :devise_default_routes (false)          Whether you will create routes as device default routes assciated with authenticated devise resource as the default target
    #   @option options [Boolean]      :api_mode              (false)          Whether you will use activity_notification controllers as REST API mode
    #   @option options [String]       :model                 (:subscriptions) Model name of subscriptions
    #   @option options [String]       :controller            ("activity_notification/subscriptions" | activity_notification/subscriptions_with_devise") :controller option as resources routing
    #   @option options [Symbol]       :as                    (nil)            :as option as resources routing
    #   @option options [Array]        :only                  (nil)            :only option as resources routing
    #   @option options [Array]        :except                (nil)            :except option as resources routing
    # @return [ActionDispatch::Routing::Mapper] Routing mapper instance
    def subscribed_by(*resources)
      options = create_options(:subscriptions, resources.extract_options!, [:new, :edit, :update])

      resources.each do |target|
        options[:defaults] = { target_type: target.to_s }.merge(options[:devise_defaults])
        resources_options = options.select { |key, _| [:api_mode, :with_devise, :devise_default_routes, :model, :devise_defaults].exclude? key }
        if options[:with_devise].present? && options[:devise_default_routes].present?
          create_subscription_routes options, resources_options
        else
          self.resources target, only: :none do
            create_subscription_routes options, resources_options
          end
        end
      end

      self
    end


    private

      # Check whether action path is ignored by :except or :only options
      # @api private
      # @return [Boolean] Whether action path is ignored
      def ignore_path?(action, options)
        options[:except].present? &&  options[:except].include?(action) and return true
        options[:only].present?   && !options[:only].include?(action)   and return true
        false
      end

      # Create options for routing
      # @api private
      # @todo Check resources if it includes target module
      # @todo Check devise configuration in model
      # @todo Support other options like :as, :path_prefix, :path_names ...
      #
      # @param [Symbol] resource Name of the resource model
      # @param [Hash] options Passed options from notify_to or subscribed_by
      # @param [Hash] except_actions Actions in [:index, :show, :new, :create, :edit, :update, :destroy] to remove routes
      # @return [Hash] Options to create routes
      def create_options(resource, options = {}, except_actions = [])
        # Check resources if it includes target module
        resources_name = resource.to_s.pluralize.underscore
        options[:model] ||= resources_name.to_sym
        controller_name = "activity_notification/#{resources_name}"
        controller_name.concat("_api") if options[:api_mode]
        if options[:with_devise].present?
          options[:controller] ||= "#{controller_name}_with_devise"
          options[:as]         ||= resources_name
          # Check devise configuration in model
          options[:devise_defaults] = { devise_type: options[:with_devise].to_s }
          options[:devise_defaults] = options[:devise_defaults].merge(options.slice(:devise_default_routes))
        else
          options[:controller] ||= controller_name
          options[:devise_defaults] = {}
        end
        (options[:except] ||= []).concat(except_actions)
        if options[:with_subscription].present?
          options[:subscription_option] = (options[:with_subscription].is_a?(Hash) ? options[:with_subscription] : {})
                                            .merge(options.slice(:api_mode, :with_devise, :devise_default_routes, :routing_scope))
        end
        # Support other options like :as, :path_prefix, :path_names ...
        options
      end

      # Create routes for notifications
      # @api private
      #
      # @param [Symbol] resource Name of the resource model
      # @param [Hash] options Passed options from notify_to
      # @param [Hash] resources_options Options to send resources method
      def create_notification_routes(options = {}, resources_options = [])
        self.resources options[:model], resources_options do
          collection do
            post :open_all unless ignore_path?(:open_all, options)
          end
          member do
            get  :move     unless ignore_path?(:move, options)
            put  :open     unless ignore_path?(:open, options)
          end
        end
      end

      # Create routes for subscriptions
      # @api private
      #
      # @param [Symbol] resource Name of the resource model
      # @param [Hash] options Passed options from subscribed_by
      # @param [Hash] resources_options Options to send resources method
      def create_subscription_routes(options = {}, resources_options = [])
        self.resources options[:model], resources_options do
          collection do
            get :find                           unless ignore_path?(:find, options)
            get :optional_target_names          if options[:api_mode] && !ignore_path?(:optional_target_names, options)
          end
          member do
            put :subscribe                      unless ignore_path?(:subscribe, options)
            put :unsubscribe                    unless ignore_path?(:unsubscribe, options)
            put :subscribe_to_email             unless ignore_path?(:subscribe_to_email, options)
            put :unsubscribe_to_email           unless ignore_path?(:unsubscribe_to_email, options)
            put :subscribe_to_optional_target   unless ignore_path?(:subscribe_to_optional_target, options)
            put :unsubscribe_to_optional_target unless ignore_path?(:unsubscribe_to_optional_target, options)
          end
        end
      end

  end
end
