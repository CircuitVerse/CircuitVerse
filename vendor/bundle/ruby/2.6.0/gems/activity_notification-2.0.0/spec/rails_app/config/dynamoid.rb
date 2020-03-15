Dynamoid.configure do |config|
  config.namespace = "activity_notification_#{Rails.env}"
  config.endpoint = 'http://localhost:8000'
  # config.store_datetime_as_string = true
end
