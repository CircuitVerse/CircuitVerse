Rails.application.config.action_mailer.delivery_method = :aws_sdk
Rails.application.config.action_mailer.aws_sdk_settings = {
  region: 'your-region',
  credentials: Aws::Credentials.new('your-access-key-id', 'your-secret-access-key')
}
