namespace :activity_notification do
  desc "Create Amazon DynamoDB tables used by activity_notification with Dynamoid"
  task create_dynamodb_tables: :environment do
    if ActivityNotification.config.orm == :dynamoid
      ActivityNotification::Notification.create_table(sync: true)
      puts "Created table: #{ActivityNotification::Notification.table_name}"
      ActivityNotification::Subscription.create_table(sync: true)
      puts "Created table: #{ActivityNotification::Subscription.table_name}"
    else
      puts "Error: ActivityNotification.config.orm is not set to :dynamoid."
      puts "Error: Confirm to set AN_ORM environment variable to dynamoid or set ActivityNotification.config.orm to :dynamoid."
    end
  end
end
