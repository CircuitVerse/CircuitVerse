# frozen_string_literal: true

module Aws
  # Use the Rails namespace.
  module Rails
    # See https://guides.rubyonrails.org/configuring.html#initializers
    # @api private
    class Railtie < ::Rails::Railtie
      # Set the logger for the AWS SDK to Rails.logger.
      initializer 'aws-sdk-rails.log-to-rails-logger', after: :initialize_logger do
        Aws.config[:logger] = ::Rails.logger
      end

      # Configures the AWS SDK with credentials from Rails encrypted credentials.
      initializer 'aws-sdk-rails.use-rails-encrypted-credentials', after: :load_environment_config do
        # limit the config keys we merge to credentials only
        aws_credential_keys = %i[access_key_id secret_access_key session_token account_id]
        creds = ::Rails.application.credentials[:aws].to_h.slice(*aws_credential_keys)
        Aws.config.merge!(creds)
      end

      # Eager load the AWS SDK Clients.
      initializer 'aws-sdk-rails.eager-load-sdk', before: :eager_load! do
        Aws.define_singleton_method(:eager_load!) do
          Aws.constants.each do |c|
            m = Aws.const_get(c)
            next unless m.is_a?(Module)

            m.constants.each do |constant|
              m.const_get(constant)
            end
          end
        end

        config.before_eager_load do
          config.eager_load_namespaces << Aws
        end
      end

      # Add ActiveSupport Notifications instrumentation to AWS SDK client operations.
      # Each operation will produce an event with a name `<operation>.<service>.aws`.
      # For example, S3's put_object has an event name of: put_object.S3.aws
      initializer 'aws-sdk-rails.instrument-sdk-operations', after: :load_active_support do
        Aws.constants.each do |c|
          m = Aws.const_get(c)
          if m.is_a?(Module) && m.const_defined?(:Client) &&
             (client = m.const_get(:Client)) && client.superclass == Seahorse::Client::Base
            m.const_get(:Client).add_plugin(Aws::Rails::Notifications)
          end
        end
      end

      # Register a middleware that will handle requests from the Elastic Beanstalk worker SQS Daemon.
      initializer 'aws-sdk-rails.add-sqsd-middleware', before: :build_middleware_stack do |app|
        Aws::Rails.add_sqsd_middleware(app)
      end
    end

    class << self
      # @api private
      def add_sqsd_middleware(app)
        return unless ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS']

        if app.config.force_ssl
          # SQS Daemon sends requests over HTTP - allow and process them before enforcing SSL.
          app.config.middleware.insert_before(::ActionDispatch::SSL, Aws::Rails::Middleware::ElasticBeanstalkSQSD)
        else
          app.config.middleware.use(Aws::Rails::Middleware::ElasticBeanstalkSQSD)
        end
      end
    end
  end
end
