# frozen_string_literal: true

module Aws
  # Use the Rails namespace.
  module Rails
    # @api private
    class Railtie < ::Rails::Railtie
      initializer 'aws-sdk-rails.initialize',
                  before: :load_config_initializers do
        # Initialization Actions
        Aws::Rails.use_rails_encrypted_credentials
        Aws::Rails.add_action_mailer_delivery_method
        Aws::Rails.log_to_rails_logger
      end

      initializer 'aws-sdk-rails.insert_middleware' do |app|
        Aws::Rails.add_sqsd_middleware(app)
      end

      rake_tasks do
        load 'tasks/dynamo_db/session_store.rake'
        load 'tasks/aws_record/migrate.rake'
      end
    end

    # This is called automatically from the SDK's Railtie, but can be manually
    # called if you want to specify options for building the Aws::SES::Client.
    #
    # @param [Symbol] name The name of the ActionMailer delivery method to
    #   register.
    # @param [Hash] options The options you wish to pass on to the
    #   Aws::SES::Client initialization method.
    def self.add_action_mailer_delivery_method(name = :ses, options = {})
      ActiveSupport.on_load(:action_mailer) do
        add_delivery_method(name, Aws::Rails::Mailer, options)
      end
    end

    # Configures the AWS SDK for Ruby's logger to use the Rails logger.
    def self.log_to_rails_logger
      Aws.config[:logger] = ::Rails.logger
      nil
    end

    # Configures the AWS SDK with credentials from Rails encrypted credentials.
    def self.use_rails_encrypted_credentials
      # limit the config keys we merge to credentials only
      aws_credential_keys = %i[access_key_id secret_access_key session_token]

      Aws.config.merge!(
        ::Rails.application.credentials[:aws].to_h.slice(*aws_credential_keys)
      )
    end

    # Adds ActiveSupport Notifications instrumentation to AWS SDK
    # client operations.  Each operation will produce an event with a name:
    # <operation>.<service>.aws.  For example, S3's put_object has an event
    # name of: put_object.S3.aws
    def self.instrument_sdk_operations
      Aws.constants.each do |c|
        m = Aws.const_get(c)
        if m.is_a?(Module) && m.const_defined?(:Client) &&
           m.const_get(:Client).superclass == Seahorse::Client::Base
          m.const_get(:Client).add_plugin(Aws::Rails::Notifications)
        end
      end
    end

    # Register a middleware that will handle requests from the Elastic Beanstalk worker SQS Daemon.
    # This will only be added in the presence of the AWS_PROCESS_BEANSTALK_WORKER_REQUESTS environment variable.
    # The expectation is this variable should only be set on EB worker environments.
    def self.add_sqsd_middleware(app)
      is_eb_worker_hosted = Aws::Util.str_2_bool(ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS'].to_s.downcase)

      return unless is_eb_worker_hosted

      if app.config.force_ssl
        # SQS Daemon sends requests over HTTP - allow and process them before enforcing SSL.
        app.config.middleware.insert_before(ActionDispatch::SSL, Aws::Rails::EbsSqsActiveJobMiddleware)
      else
        app.config.middleware.use(Aws::Rails::EbsSqsActiveJobMiddleware)
      end
    end
  end
end
