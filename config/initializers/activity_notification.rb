ActivityNotification.configure do |config|

  # Configure if all activity notifications are enabled
  # Set false when you want to turn off activity notifications
  config.enabled = true

  # Configure ORM name for ActivityNotification.
  # Set :active_record, :mongoid or :dynamoid.
  ENV['AN_ORM'] = 'active_record' if ['mongoid', 'dynamoid'].exclude?(ENV['AN_ORM'])
  config.orm = ENV['AN_ORM'].to_sym

  # Configure table name to store notification data.
  config.notification_table_name = "notifications"

  # Configure table name to store subscription data.
  config.subscription_table_name = "subscriptions"

  # Configure if email notification is enabled as default.
  # Note that you can configure them for each model by acts_as roles.
  # Set true when you want to turn on email notifications as default.
  config.email_enabled = false

  # Configure if subscription is managed.
  # Note that this parameter must be true when you want use subscription management.
  # However, you can also configure them for each model by acts_as roles.
  # Set true when you want to turn on subscription management as default.
  config.subscription_enabled = false

  # Configure default subscription value to use when the subscription record does not configured.
  # Note that you can configure them for each method calling as default argument.
  # Set false when you want to unsubscribe to any notifications as default.
  config.subscribe_as_default = true

  # Configure the e-mail address which will be shown in ActivityNotification::Mailer,
  # note that it will be overwritten if you use your own mailer class with default "from" parameter.
  config.mailer_sender = 'noreply@circuitverse.org'

  # Configure the class responsible to send e-mails.
  # config.mailer = "ActivityNotification::Mailer"

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # Configure the parent job class for delayed notifications.
  # config.parent_job = 'ActiveJob::Base'

  # Configure the parent class for activity_notification controllers.
  # config.parent_controller = 'ApplicationController'

  # Configure the parent class for activity_notification channels.
  # config.parent_channel = 'ActionCable::Channel::Base'

  # Configure the custom mailer templates directory
  # config.mailer_templates_dir = 'activity_notification/mailer'

  # Configure default limit number of opened notifications you can get from opened* scope
  config.opened_index_limit = 10

  # Configure ActiveJob queue name for delayed notifications.
  config.active_job_queue = :activity_notification

  # Configure delimiter of composite key for DynamoDB.
  # config.composite_key_delimiter = '#'

  # Configure if activity_notification stores notificaion records including associated records like target and notifiable..
  # This store_with_associated_records option can be set true only when you use mongoid or dynamoid ORM.
  config.store_with_associated_records = false

  # Configure if WebSocket subscription using ActionCable is enabled.
  # Note that you can configure them for each model by acts_as roles.
  # Set true when you want to turn on WebSocket subscription using ActionCable as default.
  config.action_cable_enabled = false

  # Configure if ctivity_notification publishes WebSocket notifications using ActionCable only to authenticated target with Devise.
  # Note that you can configure them for each model by acts_as roles.
  # Set true when you want to use Device integration with WebSocket subscription using ActionCable as default.
  config.action_cable_with_devise = false

  # Configure notification channel prefix for ActionCable.
  config.notification_channel_prefix = 'activity_notification_channel'

end
