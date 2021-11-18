require 'aws-sessionstore-dynamodb'

module ActionDispatch
  module Session
    # Uses the Dynamo DB Session Store implementation to create a class that
    # extends ActionDispatch::Session. Rails will create a :dynamodb_store
    # configuration for session_store from this class name.
    #
    # This class will use the Rails secret_key_base unless otherwise provided.
    #
    # Configuration can also be provided in YAML files from Rails config, either
    # in "config/session_store.yml" or "config/session_store/#{Rails.env}.yml".
    # Configuration files that are environment-specific will take precedence.
    #
    # @see https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html
    class DynamodbStore < Aws::SessionStore::DynamoDB::RackMiddleware
      def initialize(app, options = {})
        options[:config_file] ||= config_file if config_file.exist?
        options[:secret_key] ||= Rails.application.secret_key_base
        super
      end

      private

      def config_file
        file = Rails.root.join("config/dynamo_db_session_store/#{Rails.env}.yml")
        file = Rails.root.join('config/dynamo_db_session_store.yml') unless file.exist?
        file
      end
    end
  end
end
