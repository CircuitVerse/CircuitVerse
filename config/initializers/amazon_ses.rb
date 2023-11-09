aws_credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID_SES'], ENV['AWS_SECRET_ACCESS_KEY_SES'])

Aws::Rails.add_action_mailer_delivery_method(
  :ses,
  credentials: aws_credentials,
  region: ENV['AWS_REGION_SES']
)
