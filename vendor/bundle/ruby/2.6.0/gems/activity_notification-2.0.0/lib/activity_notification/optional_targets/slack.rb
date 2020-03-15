module ActivityNotification
  module OptionalTarget
    # Optional target implementation for Slack.
    class Slack < ActivityNotification::OptionalTarget::Base
      require 'slack-notifier'

      # Initialize method to prepare Slack::Notifier
      # @param [Hash] options Options for initializing
      # @option options [String, Proc, Symbol] :target_username (nil) Target user name of Slack, it resolved by target instance like email_allowed?
      # @option options [required, String]     :webhook_url     (nil) Webhook URL of Slack Incoming WebHooks integration
      # @option options [Hash]                 others                 Other options to be set Slack::Notifier.new, like :channel, :username, :icon_emoji etc
      def initialize_target(options = {})
        @target_username = options.delete(:target_username)
        @notifier = ::Slack::Notifier.new(options.delete(:webhook_url), options)
      end

      # Publishes notification message to Slack
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      # @option options [String, Proc, Symbol] :target_username (nil)                     Target user name of Slack, it resolved by target instance like email_allowed?
      # @option options [String]               :partial_root    ("activity_notification/optional_targets/#{target}/#{optional_target_name}", "activity_notification/optional_targets/#{target}/base", "activity_notification/optional_targets/default/#{optional_target_name}", "activity_notification/optional_targets/default/base") Partial template name
      # @option options [String]               :partial         (self.key.tr('.', '/'))   Root path of partial template
      # @option options [String]               :layout          (nil)                     Layout template name
      # @option options [String]               :layout_root     ('layouts')               Root path of layout template
      # @option options [String, Symbol]       :fallback        (:default)                Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
      # @option options [Hash]                 others                                     Parameters to be set as locals
      def notify(notification, options = {})
        target_username = notification.target.resolve_value(options.delete(:target_username) || @target_username)
        @notifier.ping(render_notification_message(notification, options.merge(assignment: { target_username: target_username })))
      end
    end
  end
end