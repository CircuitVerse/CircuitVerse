if defined?(ActiveJob)
  # Job to generate notifications by ActivityNotification::Notification#notify method.
  class ActivityNotification::NotifyJob < ActivityNotification.config.parent_job.constantize
    queue_as ActivityNotification.config.active_job_queue
  
    # Generates notifications to configured targets with notifiable model with ActiveJob.
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
    def perform(target_type, notifiable, options = {})
      ActivityNotification::Notification.notify(target_type, notifiable, options)
    end
  end
end
