require 'aws-sdk-dynamodb'
require 'logger'

module Aws::SessionStore::DynamoDB
  # This class provides a way to create and delete a session table.
  module Table
    module_function

    # Creates a session table.
    # @option (see Configuration#initialize)
    def create_table(options = {})
      config = load_config(options)
      ddb_options = properties(config.table_name, config.table_key).merge(
          throughput(config.read_capacity, config.write_capacity)
        )
      config.dynamo_db_client.create_table(ddb_options)
      logger << "Table #{config.table_name} created, waiting for activation...\n"
      block_until_created(config)
      logger << "Table #{config.table_name} is now ready to use.\n"
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      logger << "Table #{config.table_name} already exists, skipping creation.\n"
    end

    # Deletes a session table.
    # @option (see Configuration#initialize)
    def delete_table(options = {})
      config = load_config(options)
      config.dynamo_db_client.delete_table(:table_name => config.table_name)
    end

    # @api private
    def logger
      @logger ||= Logger.new($STDOUT)
    end

    # Loads configuration options.
    # @option (see Configuration#initialize)
    # @api private
    def load_config(options = {})
      Aws::SessionStore::DynamoDB::Configuration.new(options)
    end

    # @return [Hash] Attribute settings for creating a session table.
    # @api private
    def attributes(hash_key)
      attributes = [{:attribute_name => hash_key, :attribute_type => 'S'}]
      { :attribute_definitions => attributes }
    end

    # @return Shema values for session table
    # @api private
    def schema(table_name, hash_key)
      {
        :table_name => table_name,
        :key_schema => [ {:attribute_name => hash_key, :key_type => 'HASH'} ]
      }
    end

    # @return Throughput for Session table
    # @api private
    def throughput(read, write)
      units = {:read_capacity_units=> read, :write_capacity_units => write}
      { :provisioned_throughput => units }
    end

    # @return Properties for Session table
    # @api private
    def properties(table_name, hash_key)
      attributes(hash_key).merge(schema(table_name, hash_key))
    end

    # @api private
    def block_until_created(config)
      created = false
      until created
        params = { :table_name => config.table_name }
        response = config.dynamo_db_client.describe_table(params)
        created = response[:table][:table_status] == 'ACTIVE'

        sleep 10
      end
    end

  end
end
