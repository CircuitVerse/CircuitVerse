module ActivityNotification
  # Provides logic for rendering notifications.
  # Handles both i18n strings support and smart partials rendering (different templates per the notification key).
  # This module deeply uses PublicActivity gem as reference.
  module Renderable
    # Virtual attribute returning text description of the notification
    # using the notification's key to translate using i18n.
    #
    # @param [Hash] params Parameters for rendering notification text
    # @option params [String] :target Target type name to use as i18n text key
    # @option params [Hash] others Parameters to be referred in i18n text
    # @return [String] Rendered text
    def text(params = {})
      k = key.split('.')
      k.unshift('notification') if k.first != 'notification'
      if params.has_key?(:target)
        k.insert(1, params[:target])
      else
        k.insert(1, target.to_resource_name)
      end
      k.push('text')
      k = k.join('.')

      attrs = (parameters.symbolize_keys.merge(params) || {}).merge(
        group_member_count:          group_member_count,
        group_notification_count:    group_notification_count,
        group_member_notifier_count: group_member_notifier_count,
        group_notifier_count:        group_notifier_count
      )

      # Generate the :default fallback key without using pluralization key :count
      default = I18n.t(k, attrs)
      I18n.t(k, attrs.merge(count: group_notification_count, default: default))
    end

    # Renders notification from views.
    #
    # The preferred way of rendering notifications is
    # to provide a template specifying how the rendering should be happening.
    # However, you can choose using _i18n_ based approach when developing
    # an application that supports plenty of languages.
    #
    # If partial view exists that matches the "target" type and "key" attribute
    # renders that partial with local variables set to contain both
    # Notification and notification_parameters (hash with indifferent access).
    #
    # If the partial view does not exist and you wish to fallback to rendering
    # through the i18n translation, you can do so by passing in a :fallback
    # parameter whose value equals :text.
    #
    # If you do not want to define a partial view, and instead want to have
    # all missing views fallback to a default, you can define the :fallback
    # value equal to the partial you wish to use when the partial defined
    # by the notification key does not exist.
    #
    # Render a list of all notifications of @target from a view (erb):
    #   <ul>
    #     <% @target.notifications.each do |notification|  %>
    #       <li><%= render_notification notification %></li>
    #     <% end %>
    #   </ul>
    #
    # Fallback to the i18n text translation if the view is missing:
    #   <ul>
    #     <% @target.notifications.each do |notification|  %>
    #       <li><%= render_notification notification, fallback: :text %></li>
    #     <% end %>
    #   </ul>
    #
    # Fallback to a default view if the view for the current notification key is missing:
    #   <ul>
    #     <% @target.notifications.each do |notification|  %>
    #       <li><%= render_notification notification, fallback: 'default' %></li>
    #     <% end %>
    #   </ul>
    #
    # = Layouts
    #
    # You can supply a layout that will be used for notification partials
    # with :layout param.
    # Keep in mind that layouts for partials are also partials.
    #
    # Supply a layout:
    #   # in views:
    #   # All examples look for a layout in app/views/layouts/_notification.erb
    #   render_notification @notification, layout: "notification"
    #   render_notification @notification, layout: "layouts/notification"
    #   render_notification @notification, layout: :notification
    #
    #   # app/views/layouts/_notification.erb
    #   <p><%= notification.created_at %></p>
    #   <%= yield %>
    #
    # == Custom Layout Location
    #
    # You can customize the layout directory by supplying :layout_root
    # or by using an absolute path.
    #
    # Declare custom layout location:
    #   # Both examples look for a layout in "app/views/custom/_layout.erb"
    #   render_notification @notification, layout_root: "custom"
    #   render_notification @notification, layout: "/custom/layout"
    #
    # = Creating a template
    #
    # To use templates for formatting how the notification should render,
    # create a template based on target type and notification key, for example:
    #
    # Given a target type users and key _notification.article.create_, create directory tree
    # _app/views/activity_notification/notifications/users/article/_ and create the _create_ partial there
    #
    # Note that if a key consists of more than three parts splitted by commas, your
    # directory structure will have to be deeper, for example:
    #   notification.article.comment.reply => app/views/activity_notification/notifications/users/article/comment/_reply.html.erb
    #
    # == Custom Directory
    #
    # You can override the default `activity_notification/notifications/#{target}` template root with the :partial_root parameter.
    #
    # Custom template root:
    #    # look for templates inside of /app/views/custom instead of /app/views/public_directory/activity_notification/notifications/#{target}
    #    render_notification @notification, partial_root: "custom"
    #
    # == Variables in templates
    #
    # From within a template there are three variables at your disposal:
    # * notification
    # * controller
    # * parameters [converted into a HashWithIndifferentAccess]
    #
    # Template for key: _notification.article.create_ (erb):
    #   <p>
    #     Article <strong><%= parameters[:title] %></strong>
    #     was posted by <em><%= parameters["author"] %></em>
    #     <%= distance_of_time_in_words_to_now(notification.created_at) %>
    #   </p>
    #
    # @param [ActionView::Base] context
    # @param [Hash] params Parameters for rendering notifications
    # @option params [String, Symbol] :target       (nil)                     Target type name to find template or i18n text
    # @option params [String]         :partial_root ("activity_notification/notifications/#{target}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name
    # @option params [String]         :partial      (self.key.tr('.', '/'))   Root path of partial template
    # @option params [String]         :layout       (nil)                     Layout template name
    # @option params [String]         :layout_root  ('layouts')               Root path of layout template
    # @option params [String, Symbol] :fallback     (nil)                     Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
    # @option params [Hash]           others                                  Parameters to be set as locals
    # @return [String] Rendered view or text as string
    def render(context, params = {})
      params[:i18n] and return context.render plain: self.text(params)

      partial = partial_path(*params.values_at(:partial, :partial_root, :target))
      layout  = layout_path(*params.values_at(:layout, :layout_root))
      locals  = prepare_locals(params)

      begin
        context.render params.merge(partial: partial, layout: layout, locals: locals)
      rescue ActionView::MissingTemplate => e
        if params[:fallback] == :text
          context.render plain: self.text(params)
        elsif params[:fallback].present?
          partial = partial_path(*params.values_at(:fallback, :partial_root, :target))
          context.render params.merge(partial: partial, layout: layout, locals: locals)
        else
          raise e
        end
      end
    end

    # Returns partial path from options
    #
    # @param [String] path Partial template name
    # @param [String] root Root path of partial template
    # @param [String, Symbol] target Target type name to find template
    # @return [String] Partial template path
    def partial_path(path = nil, root = nil, target = nil)
      controller = ActivityNotification.get_controller         if ActivityNotification.respond_to?(:get_controller)
      root ||= "activity_notification/notifications/#{target}" if target.present?
      root ||= controller.target_view_path                     if controller.present? && controller.respond_to?(:target_view_path)
      root ||= 'activity_notification/notifications/default'
      template_key = notifiable.respond_to?(:overriding_notification_template_key) &&
                     notifiable.overriding_notification_template_key(@target, key).present? ?
                       notifiable.overriding_notification_template_key(@target, key) :
                       key
      path ||= template_key.tr('.', '/')
      select_path(path, root)
    end

    # Returns layout path from options
    #
    # @param [String] path Layout template name
    # @param [String] root Root path of layout template
    # @return [String] Layout template path
    def layout_path(path = nil, root = nil)
      path.nil? and return
      root ||= 'layouts'
      select_path(path, root)
    end

    # Returns locals parameter for view
    # There are three variables to be add by method:
    # * notification
    # * controller
    # * parameters [converted into a HashWithIndifferentAccess]
    #
    # @param [Hash] params Parameters to add parameters at locals
    # @return [Hash] locals parameter
    def prepare_locals(params)
      locals = params.delete(:locals) || {}
      prepared_parameters = prepare_parameters(params)
      locals.merge\
        notification: self,
        controller:   ActivityNotification.get_controller,
        parameters:   prepared_parameters
    end

    # Prepares parameters with @prepared_params.
    # Converted into a HashWithIndifferentAccess.
    #
    # @param [Hash] params Parameters to prepare
    # @return [Hash] Prepared parameters
    def prepare_parameters(params)
      @prepared_params ||= ActivityNotification.cast_to_indifferent_hash(parameters).merge(params)
    end


    private

      # Select template path
      # @api private
      def select_path(path, root)
        [root, path].map(&:to_s).join('/')
      end

  end
end
