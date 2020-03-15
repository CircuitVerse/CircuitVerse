module ActivityNotification
  module OptionalTarget
    # Optional target implementation for mobile push notification or SMS using Amazon SNS.
    class AmazonSNS < ActivityNotification::OptionalTarget::Base
      begin
        require 'aws-sdk'
      rescue LoadError
        require 'aws-sdk-sns'
      end

      # Initialize method to prepare Aws::SNS::Client
      # @param [Hash] options Options for initializing
      # @option options [String, Proc, Symbol] :topic_arn    (nil) :topic_arn option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [String, Proc, Symbol] :target_arn   (nil) :target_arn option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [String, Proc, Symbol] :phone_number (nil) :phone_number option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [Hash]                 others              Other options to be set Aws::SNS::Client.new
      def initialize_target(options = {})
        @topic_arn    = options.delete(:topic_arn)
        @target_arn   = options.delete(:target_arn)
        @phone_number = options.delete(:phone_number)
        @sns_client = Aws::SNS::Client.new(options)
      end

      # Publishes notification message to Amazon SNS
      # @param [Notification] notification Notification instance
      # @param [Hash] options Options for publishing
      # @option options [String, Proc, Symbol] :topic_arn    (nil)                     :topic_arn option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [String, Proc, Symbol] :target_arn   (nil)                     :target_arn option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [String, Proc, Symbol] :phone_number (nil)                     :phone_number option for Aws::SNS::Client#publish, it resolved by target instance like email_allowed?
      # @option options [String]               :partial_root ("activity_notification/optional_targets/#{target}/#{optional_target_name}", "activity_notification/optional_targets/#{target}/base", "activity_notification/optional_targets/default/#{optional_target_name}", "activity_notification/optional_targets/default/base") Partial template name
      # @option options [String]               :partial      (self.key.tr('.', '/'))   Root path of partial template
      # @option options [String]               :layout       (nil)                     Layout template name
      # @option options [String]               :layout_root  ('layouts')               Root path of layout template
      # @option options [String, Symbol]       :fallback     (:default)                Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
      # @option options [Hash]                 others                                  Parameters to be set as locals
      def notify(notification, options = {})
        @sns_client.publish(
          topic_arn:    notification.target.resolve_value(options.delete(:topic_arn) || @topic_arn),
          target_arn:   notification.target.resolve_value(options.delete(:target_arn) || @target_arn),
          phone_number: notification.target.resolve_value(options.delete(:phone_number) || @phone_number),
          message: render_notification_message(notification, options)
        )
      end
    end
  end
end