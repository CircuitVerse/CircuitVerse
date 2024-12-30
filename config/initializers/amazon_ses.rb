require 'aws-sdk-ses'

ActionMailer::Base.add_delivery_method(
  :ses,
  Aws::SES::Client,  
  region: ENV['AWS_REGION_SES'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID_SES'], ENV['AWS_SECRET_ACCESS_KEY_SES'])
)