module ActivityNotification
  # Optional target module to develop optional notification target classes.
  module OptionalTarget
    # Abstract optional target class to develop optional notification target class.
    class Base
      # Initialize method to create view context in this OptionalTarget instance
      # @param [Hash] options Options for initializing target
      # @option options [Boolean] :skip_initializing_target (false) Whether skip calling initialize_target method
      # @option options [Hash]    others                            Options for initializing target
      def initialize(options = {})
        initialize_target(options) unless options.delete(:skip_initializing_target)
      end

      # Returns demodulized symbol class name as optional target name
      # @return Demodulized symbol class name as optional target name
      def to_optional_target_name
        self.class.name.demodulize.underscore.to_sym
      end

      # Initialize method to be overridden in user implementation class
      # @param [Hash] _options Options for initializing
      def initialize_target(_options = {})
        raise NotImplementedError, "You have to implement #{self.class}##{__method__}"
      end

      # Publishing notification method to be overridden in user implementation class
      # @param [Notification] _notification Notification instance
      # @param [Hash] _options Options for publishing
      def notify(_notification, _options = {})
        raise NotImplementedError, "You have to implement #{self.class}##{__method__}"
      end

      protected

        # Renders notification message with view context
        # @param [Notification] notification Notification instance
        # @param [Hash]         options      Options for rendering
        # @option options [Hash]           :assignment   (nil)                     Optional instance variables to assign for views
        # @option options [String]         :partial_root ("activity_notification/optional_targets/#{target}/#{optional_target_name}", "activity_notification/optional_targets/#{target}/base", "activity_notification/optional_targets/default/#{optional_target_name}", "activity_notification/optional_targets/default/base") Partial template name
        # @option options [String]         :partial      (self.key.tr('.', '/'))   Root path of partial template
        # @option options [String]         :layout       (nil)                     Layout template name
        # @option options [String]         :layout_root  ('layouts')               Root path of layout template
        # @option options [String, Symbol] :fallback     (:default)                Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
        # @option options [Hash]           others                                  Parameters to be set as locals
        # @return [String] Rendered view or text as string
        def render_notification_message(notification, options = {})
          partial_root_list = 
            options[:partial_root].present? ?
            [ options[:partial_root] ] :
            [ "activity_notification/optional_targets/#{notification.target.to_resources_name}/#{to_optional_target_name}",
              "activity_notification/optional_targets/#{notification.target.to_resources_name}/base",
              "activity_notification/optional_targets/default/#{to_optional_target_name}",
              "activity_notification/optional_targets/default/base"
            ]
          options[:fallback] ||= :default

          message, missing_template = nil, nil
          partial_root_list.each do |partial_root|
            begin
              message = notification.render(
                ActivityNotification::NotificationsController.renderer,
                options.merge(
                  partial_root: partial_root,
                  assigns: (options[:assignment] || {}).merge(notification: notification, target: notification.target)
                )
              ).to_s
              break
            rescue ActionView::MissingTemplate => e
              missing_template = e
              # Continue to next partial root
            end
          end
          message.blank? ? (raise missing_template) : message
        end
    end
  end
end