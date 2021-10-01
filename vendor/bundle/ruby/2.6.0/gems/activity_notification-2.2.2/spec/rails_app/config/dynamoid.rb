Dynamoid.configure do |config|
  config.namespace = ENV['AN_NO_DYNAMODB_NAMESPACE'] ? "" : "activity_notification_#{Rails.env}"
  # TODO Update Dynamoid v3.4.0+
  # config.capacity_mode = :on_demand
  config.read_capacity = 5
  config.write_capacity = 5
  unless Rails.env.production?
    config.endpoint = 'http://localhost:8000'
  end
  unless Rails.env.test?
    config.store_datetime_as_string = true
  end
end
