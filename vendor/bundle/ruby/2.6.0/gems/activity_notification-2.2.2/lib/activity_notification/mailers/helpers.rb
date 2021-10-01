module ActivityNotification
  # Mailer module of ActivityNotification
  module Mailers
    # Provides helper methods for mailer.
    # Use to resolve parameters from email configuration and send notification email.
    module Helpers
      extend ActiveSupport::Concern

      protected

        # Send notification email with configured options.
        #
        # @param [Notification] notification Notification instance to send email
        # @param [Hash]         options      Options for notification email
        # @option options [String, Symbol] :fallback (:default) Fallback template to use when MissingTemplate is raised
        def notification_mail(notification, options = {})
          initialize_from_notification(notification)
          headers = headers_for(notification.key, options)
          send_mail(headers, options[:fallback])
        end

        # Send batch notification email with configured options.
        #
        # @param [Object]              target        Target of batch notification email
        # @param [Array<Notification>] notifications Target notifications to send batch notification email
        # @param [String]              batch_key     Key of the batch notification email
        # @param [Hash]                options       Options for notification email
        # @option options [String, Symbol] :fallback (:batch_default) Fallback template to use when MissingTemplate is raised
        def batch_notification_mail(target, notifications, batch_key, options = {})
          initialize_from_notifications(target, notifications)
          headers = headers_for(batch_key, options)
          @notification = nil
          send_mail(headers, options[:fallback])
        end

        # Initialize instance variables from notification.
        #
        # @param [Notification] notification Notification instance
        def initialize_from_notification(notification)
          @notification, @target, @batch_email = notification, notification.target, false
        end

        # Initialize instance variables from notifications.
        #
        # @param [Object]              target        Target of batch notification email
        # @param [Array<Notification>] notifications Target notifications to send batch notification email
        def initialize_from_notifications(target, notifications)
          @target, @notifications, @notification, @batch_email = target, notifications, notifications.first, true
        end

        # Prepare email header from notification key and options.
        #
        # @param [String] key Key of the notification
        # @param [Hash] options Options for email notification
        def headers_for(key, options)
          if !@batch_email &&
             @notification.notifiable.respond_to?(:overriding_notification_email_key) &&
             @notification.notifiable.overriding_notification_email_key(@target, key).present?
            key = @notification.notifiable.overriding_notification_email_key(@target, key)
          end
          headers = {
            to: mailer_to(@target),
            template_path: template_paths,
            template_name: template_name(key)
          }.merge(options)
          {
            subject: :subject_for,
            from: :mailer_from,
            reply_to: :mailer_reply_to,
            message_id: nil
          }.each do |header_name, default_method|
            overridding_method_name = "overriding_notification_email_#{header_name.to_s}"
            header_value = if @notification.notifiable.respond_to?(overridding_method_name) &&
                @notification.notifiable.send(overridding_method_name, @target, key).present?
              @notification.notifiable.send(overridding_method_name, @target, key)
            elsif default_method
              send(default_method, key)
            else
              nil
            end
            headers[header_name] = header_value if header_value
          end
          @email = headers[:to]
          headers
        end

        # Returns target email address as 'to'.
        #
        # @param [Object] target Target instance to notify
        # @return [String] Target email address as 'to'
        def mailer_to(target)
          target.mailer_to
        end

        # Returns sender email address as 'reply_to'.
        #
        # @param [String] key Key of the notification or batch notification email
        # @return [String] Sender email address as 'reply_to'
        def mailer_reply_to(key)
          mailer_sender(key, :reply_to)
        end

        # Returns sender email address as 'from'.
        #
        # @param [String] key Key of the notification or batch notification email
        # @return [String] Sender email address as 'from'
        def mailer_from(key)
          mailer_sender(key, :from)
        end

        # Returns sender email address configured in initializer or mailer class.
        #
        # @param [String] key Key of the notification or batch notification email
        # @return [String] Sender email address configured in initializer or mailer class
        def mailer_sender(key, sender = :from)
          default_sender = default_params[sender]
          if default_sender.present?
            default_sender.respond_to?(:to_proc) ? instance_eval(&default_sender) : default_sender
          elsif ActivityNotification.config.mailer_sender.is_a?(Proc)
            ActivityNotification.config.mailer_sender.call(key)
          else
            ActivityNotification.config.mailer_sender
          end
        end

        # Returns template paths to find email view
        #
        # @return [Array<String>] Template paths to find email view
        def template_paths
          paths = ["#{ActivityNotification.config.mailer_templates_dir}/default"]
          paths.unshift("#{ActivityNotification.config.mailer_templates_dir}/#{@target.to_resources_name}") if @target.present?
          paths
        end

        # Returns template name from notification key
        #
        # @param [String] key Key of the notification
        # @return [String] Template name
        def template_name(key)
          key.tr('.', '/')
        end


        # Set up a subject doing an I18n lookup.
        # At first, it attempts to set a subject based on the current mapping:
        #   en:
        #     notification:
        #       {target}:
        #         {key}:
        #           mail_subject: '...'
        #
        # If one does not exist, it fallbacks to default:
        #   Notification for #{notification.printable_notifiable_type}
        #
        # @param [String] key Key of the notification
        # @return [String] Subject of notification email
        def subject_for(key)
          k = key.split('.')
          k.unshift('notification') if k.first != 'notification'
          k.insert(1, @target.to_resource_name)
          k = k.join('.')
          I18n.t(:mail_subject, scope: k,
            default: ["Notification of #{@notification.notifiable.printable_type.downcase}"])
        end


      private

        # Send email with fallback option.
        #
        # @param [Hash]           headers  Prepared email header
        # @param [String, Symbol] fallback Fallback option
        def send_mail(headers, fallback = nil)
          begin
            mail headers
          rescue ActionView::MissingTemplate => e
            if fallback.present?
              mail headers.merge(template_name: fallback)
            else
              raise e
            end
          end
        end

    end
  end
end
