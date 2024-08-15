# frozen_string_literal: true

require_relative 'aws/rails/mailer'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/notifications'
require_relative 'aws/rails/sqs_active_job/configuration'
require_relative 'aws/rails/sqs_active_job/executor'
require_relative 'aws/rails/sqs_active_job/job_runner'
require_relative 'aws/rails/sqs_active_job/lambda_handler'
require_relative 'aws/rails/middleware/ebs_sqs_active_job_middleware'

require_relative 'action_dispatch/session/dynamodb_store'
require_relative 'active_job/queue_adapters/amazon_sqs_adapter'
require_relative 'active_job/queue_adapters/amazon_sqs_async_adapter'

require_relative 'generators/aws_record/base'

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end
