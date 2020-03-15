module ActivityNotification
  # Provides a shortcut from views to the rendering method.
  # Module extending ActionView::Base and adding `render_notification` helper.
  module ViewHelpers
    # View helper for rendering an notification, calls {Notification#render} internally.
    # @see Notification#render
    #
    # @param [Notification, Array<Notificaion>] notifications Array or single instance of notifications to render
    # @param [Hash] options Options for rendering notifications
    # @option options [String, Symbol] :target       (nil)                     Target type name to find template or i18n text
    # @option options [String]         :partial      ("activity_notification/notifications/#{target}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name
    # @option options [String]         :partial_root (self.key.gsub('.', '/')) Root path of partial template
    # @option options [String]         :layout       (nil)                     Layout template name
    # @option options [String]         :layout_root  ('layouts')               Root path of layout template
    # @option options [String, Symbol] :fallback     (nil)                     Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
    # @return [String] Rendered view or text as string
    def render_notification(notifications, options = {})
      if notifications.is_a? ActivityNotification::Notification
        notifications.render self, options
      elsif notifications.respond_to?(:map)
        return nil if (notifications.respond_to?(:empty?) ? notifications.empty? : notifications.to_a.empty?)
        notifications.map {|notification| notification.render self, options.dup }.join.html_safe
      end
    end
    alias_method :render_notifications, :render_notification

    # View helper for rendering on notifications of the target to embedded partial template.
    # It calls {Notification#render} to prepare view as `content_for :index_content`
    # and render partial index calling `yield :index_content` internally.
    # For example, this method can be used for notification index as dropdown in common header.
    # @todo Show examples
    #
    # @param [Object] target Target instance of the rendering notifications
    # @param [Hash] options Options for rendering notifications
    # @option options [String, Symbol] :target                 (nil)       Target type name to find template or i18n text
    # @option options [Symbol]         :index_content          (:with_attributes) Option method to load target notification index, [:simple, :unopened_simple, :opened_simple, :with_attributes, :unopened_with_attributes, :opened_with_attributes, :none] are available
    # @option options [String]         :partial_root           ("activity_notification/notifications/#{target.to_resources_name}", 'activity_notification/notifications/default') Root path of partial template
    # @option options [String]         :notification_partial   ("activity_notification/notifications/#{target.to_resources_name}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name of the notification index content
    # @option options [String]         :layout_root            ('layouts') Root path of layout template
    # @option options [String]         :notification_layout    (nil)       Layout template name of the notification index content
    # @option options [String]         :fallback               (nil)       Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
    # @option options [String]         :partial                ('index')   Partial template name of the partial index
    # @option options [String]         :routing_scope          (nil)       Routing scope for notification and subscription routes
    # @option options [Boolean]        :devise_default_routes  (false)     If links in default views will be handles as devise default routes
    # @option options [String]         :layout                 (nil)       Layout template name of the partial index
    # @option options [Integer]        :limit                  (nil)       Limit to query for notifications
    # @option options [Boolean]        :reverse                (false)     If notification index will be ordered as earliest first
    # @option options [Boolean]        :with_group_members     (false)     If notification index will include group members
    # @option options [String]         :filtered_by_type       (nil)       Notifiable type for filter
    # @option options [Object]         :filtered_by_group      (nil)       Group instance for filter
    # @option options [String]         :filtered_by_group_type (nil)       Group type for filter, valid with :filtered_by_group_id
    # @option options [String]         :filtered_by_group_id   (nil)       Group instance id for filter, valid with :filtered_by_group_type
    # @option options [String]         :filtered_by_key        (nil)       Key of the notification for filter
    # @option options [Array]          :custom_filter          (nil)       Custom notification filter (e.g. ["created_at >= ?", time.hour.ago])
    # @return [String] Rendered view or text as string
    def render_notification_of(target, options = {})
      return unless target.is_a? ActivityNotification::Target

      # Prepare content for notifications index
      notification_options = options.merge( target: target.to_resources_name,
                                            partial: options[:notification_partial],
                                            layout: options[:notification_layout] )
      index_options = options.slice( :limit, :reverse, :with_group_members, :as_latest_group_member,
                                     :filtered_by_group, :filtered_by_group_type, :filtered_by_group_id,
                                     :filtered_by_type, :filtered_by_key, :custom_filter )
      notification_index = load_notification_index(target, options[:index_content], index_options)
      prepare_content_for(target, notification_index, notification_options)

      # Render partial index
      render_partial_index(target, options)
    end
    alias_method :render_notifications_of, :render_notification_of

    # Returns notifications_path for the target
    #
    # @param [Object] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] notifications_path for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def notifications_path_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}notifications_path", options) :
        send("#{routing_scope(options)}#{target.to_resource_name}_notifications_path", target, options)
    end

    # Returns notification_path for the notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] notification_path for the notification
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def notification_path_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}notification_path", notification, options) :
        send("#{routing_scope(options)}#{notification.target.to_resource_name}_notification_path", notification.target, notification, options)
    end

    # Returns move_notification_path for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] move_notification_path for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def move_notification_path_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("move_#{routing_scope(options)}notification_path", notification, options) :
        send("move_#{routing_scope(options)}#{notification.target.to_resource_name}_notification_path", notification.target, notification, options)
    end

    # Returns open_notification_path for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_notification_path for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def open_notification_path_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("open_#{routing_scope(options)}notification_path", notification, options) :
        send("open_#{routing_scope(options)}#{notification.target.to_resource_name}_notification_path", notification.target, notification, options)
    end

    # Returns open_all_notifications_path for the target
    #
    # @param [Object] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] open_all_notifications_path for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def open_all_notifications_path_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("open_all_#{routing_scope(options)}notifications_path", options) :
        send("open_all_#{routing_scope(options)}#{target.to_resource_name}_notifications_path", target, options)
    end

    # Returns notifications_url for the target
    #
    # @param [Object] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] notifications_url for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def notifications_url_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}notifications_url", options) :
        send("#{routing_scope(options)}#{target.to_resource_name}_notifications_url", target, options)
    end

    # Returns notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] notification_url for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def notification_url_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}notification_url", notification, options) :
        send("#{routing_scope(options)}#{notification.target.to_resource_name}_notification_url", notification.target, notification, options)
    end

    # Returns move_notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] move_notification_url for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def move_notification_url_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("move_#{routing_scope(options)}notification_url", notification, options) :
        send("move_#{routing_scope(options)}#{notification.target.to_resource_name}_notification_url", notification.target, notification, options)
    end

    # Returns open_notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_notification_url for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def open_notification_url_for(notification, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("open_#{routing_scope(options)}notification_url", notification, options) :
        send("open_#{routing_scope(options)}#{notification.target.to_resource_name}_notification_url", notification.target, notification, options)
    end

    # Returns open_all_notifications_url for the target of specified notification
    #
    # @param [Target] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] open_all_notifications_url for the target
    # @todo Needs any other better implementation
    # @todo Must handle devise namespace
    def open_all_notifications_url_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("open_all_#{routing_scope(options)}notifications_url", options) :
        send("open_all_#{routing_scope(options)}#{target.to_resource_name}_notifications_url", target, options)
    end

    # Returns subscriptions_path for the target
    #
    # @param [Object] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] subscriptions_path for the target
    # @todo Needs any other better implementation
    def subscriptions_path_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}subscriptions_path", options) :
        send("#{routing_scope(options)}#{target.to_resource_name}_subscriptions_path", target, options)
    end

    # Returns subscription_path for the subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}subscription_path", subscription, options) :
        send("#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end

    # Returns subscribe_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def subscribe_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_#{routing_scope(options)}subscription_path", subscription, options) :
        send("subscribe_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :subscribe_path_for, :subscribe_subscription_path_for

    # Returns unsubscribe_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_#{routing_scope(options)}subscription_path", subscription, options) :
        send("unsubscribe_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_path_for, :unsubscribe_subscription_path_for

    # Returns subscribe_to_email_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def subscribe_to_email_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_to_email_#{routing_scope(options)}subscription_path", subscription, options) :
        send("subscribe_to_email_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :subscribe_to_email_path_for, :subscribe_to_email_subscription_path_for

    # Returns unsubscribe_to_email_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_to_email_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_to_email_#{routing_scope(options)}subscription_path", subscription, options) :
        send("unsubscribe_to_email_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_to_email_path_for, :unsubscribe_to_email_subscription_path_for

    # Returns subscribe_to_optional_target_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def subscribe_to_optional_target_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_to_optional_target_#{routing_scope(options)}subscription_path", subscription, options) :
        send("subscribe_to_optional_target_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :subscribe_to_optional_target_path_for, :subscribe_to_optional_target_subscription_path_for

    # Returns unsubscribe_to_optional_target_subscription_path for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_path for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_to_optional_target_subscription_path_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_to_optional_target_#{routing_scope(options)}subscription_path", subscription, options) :
        send("unsubscribe_to_optional_target_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_path", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_to_optional_target_path_for, :unsubscribe_to_optional_target_subscription_path_for

    # Returns subscriptions_url for the target
    #
    # @param [Object] target Target instance
    # @param [Hash] params Request parameters
    # @return [String] subscriptions_url for the target
    # @todo Needs any other better implementation
    def subscriptions_url_for(target, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}subscriptions_url", options) :
        send("#{routing_scope(options)}#{target.to_resource_name}_subscriptions_url", target, options)
    end

    # Returns subscription_url for the subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("#{routing_scope(options)}subscription_url", subscription, options) :
        send("#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end

    # Returns subscribe_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def subscribe_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_#{routing_scope(options)}subscription_url", subscription, options) :
        send("subscribe_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :subscribe_url_for, :subscribe_subscription_url_for

    # Returns unsubscribe_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_#{routing_scope(options)}subscription_url", subscription, options) :
        send("unsubscribe_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_url_for, :unsubscribe_subscription_url_for

    # Returns subscribe_to_email_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def subscribe_to_email_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_to_email_#{routing_scope(options)}subscription_url", subscription, options) :
        send("subscribe_to_email_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :subscribe_to_email_url_for, :subscribe_to_email_subscription_url_for

    # Returns unsubscribe_to_email_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_to_email_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_to_email_#{routing_scope(options)}subscription_url", subscription, options) :
        send("unsubscribe_to_email_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_to_email_url_for, :unsubscribe_to_email_subscription_url_for

    # Returns subscribe_to_optional_target_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def subscribe_to_optional_target_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("subscribe_to_optional_target_#{routing_scope(options)}subscription_url", subscription, options) :
        send("subscribe_to_optional_target_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :subscribe_to_optional_target_url_for, :subscribe_to_optional_target_subscription_url_for

    # Returns unsubscribe_to_optional_target_subscription_url for the target of specified subscription
    #
    # @param [Subscription] subscription Subscription instance
    # @param [Hash] params Request parameters
    # @return [String] subscription_url for the subscription
    # @todo Needs any other better implementation
    def unsubscribe_to_optional_target_subscription_url_for(subscription, params = {})
      options = params.dup
      options.delete(:devise_default_routes) ?
        send("unsubscribe_to_optional_target_#{routing_scope(options)}subscription_url", subscription, options) :
        send("unsubscribe_to_optional_target_#{routing_scope(options)}#{subscription.target.to_resource_name}_subscription_url", subscription.target, subscription, options)
    end
    alias_method :unsubscribe_to_optional_target_url_for, :unsubscribe_to_optional_target_subscription_url_for

    private

      # Load notification index from :index_content parameter
      # @api private
      #
      # @param [Object] target Notification target instance
      # @param [Symbol] index_content Method to load target notification index, [:simple, :unopened_simple, :opened_simple, :with_attributes, :unopened_with_attributes, :opened_with_attributes, :none] are available
      # @param [Hash] options Option parameter to load notification index
      # @return [Array<Notification>] Array of notification index
      def load_notification_index(target, index_content, options = {})
        case index_content
        when :simple                   then target.notification_index(options)
        when :unopened_simple          then target.unopened_notification_index(options)
        when :opened_simple            then target.opened_notification_index(options)
        when :with_attributes          then target.notification_index_with_attributes(options)
        when :unopened_with_attributes then target.unopened_notification_index_with_attributes(options)
        when :opened_with_attributes   then target.opened_notification_index_with_attributes(options)
        when :none                     then []
        else                                target.notification_index_with_attributes(options)
        end
      end

      # Prepare content for notification index
      # @api private
      #
      # @param [Object] target Notification target instance
      # @param [Array<Notificaion>] notification_index Array notification index
      # @param [Hash] params Option parameter to send render_notification
      def prepare_content_for(target, notification_index, params)
        content_for :notification_index do
          @target = target
          begin
            render_notification notification_index, params
          rescue ActionView::MissingTemplate
            params.delete(:target)
            render_notification notification_index, params
          end
        end
      end

      # Render partial index of notifications
      # @api private
      #
      # @param [Object] target        Notification target instance
      # @param [Hash]   params        Option parameter to send render
      # @return [String] Rendered partial index view as string
      def render_partial_index(target, params)
        index_path = params.delete(:partial)
        partial    = partial_index_path(target, index_path, params[:partial_root])
        layout     = layout_path(params.delete(:layout), params[:layout_root])
        locals     = (params[:locals] || {}).merge(target: target, parameters: params)
        begin
          render params.merge(partial: partial, layout: layout, locals: locals)
        rescue ActionView::MissingTemplate
          partial = partial_index_path(target, index_path, 'activity_notification/notifications/default')
          render params.merge(partial: partial, layout: layout, locals: locals)
        end
      end

      # Returns partial index path from options
      # @api private
      #
      # @param [Object] target Notification target instance
      # @param [String] path Partial index template name
      # @param [String] root Root path of partial index template
      # @return [String] Partial index template path
      def partial_index_path(target, path = nil, root = nil)
        path ||= 'index'
        root ||= "activity_notification/notifications/#{target.to_resources_name}"
        select_path(path, root)
      end

      # Returns layout path from options
      # @api private
      #
      # @param [String] path Layout template name
      # @param [String] root Root path of layout template
      # @return [String] Layout template path
      def layout_path(path = nil, root = nil)
        path.nil? and return
        root ||= 'layouts'
        select_path(path, root)
      end

      # Select template path
      # @api private
      def select_path(path, root)
        [root, path].map(&:to_s).join('/')
      end

      # Prepare routing scope from options
      # @api private
      def routing_scope(options = {})
        options[:routing_scope] ? options.delete(:routing_scope).to_s + '_' : ''
      end

  end

  ActionView::Base.class_eval { include ViewHelpers }
end