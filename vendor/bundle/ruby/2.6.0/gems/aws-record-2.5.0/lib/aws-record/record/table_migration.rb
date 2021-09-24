# Copyright 2015-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License is
# located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions
# and limitations under the License.

module Aws
  module Record
    class TableMigration

      # @!attribute [rw] client
      #   @return [Aws::DynamoDB::Client] the
      #     {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html Aws::DynamoDB::Client}
      #     class used by this table migration instance.
      attr_accessor :client

      # @param [Aws::Record] model a model class that includes {Aws::Record}.
      # @param [Hash] opts
      # @option opts [Aws::DynamoDB::Client] :client Allows you to inject your
      #  own
      #  {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html Aws::DynamoDB::Client}
      #  class. If this option is not included, a client will be constructed for
      #  you with default parameters.
      def initialize(model, opts = {})
        _assert_model_valid(model)
        @model = model
        @client = opts[:client] || model.dynamodb_client || Aws::DynamoDB::Client.new
      end

      # This method calls
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#create_table-instance_method Aws::DynamoDB::Client#create_table},
      # populating the attribute definitions and key schema based on your model
      # class, as well as passing through other parameters as provided by you.
      #
      # @example Creating a table with a global secondary index named +:gsi+
      #   migration.create!(
      #     provisioned_throughput: {
      #       read_capacity_units: 5,
      #       write_capacity_units: 2
      #     },
      #     global_secondary_index_throughput: {
      #       gsi: {
      #         read_capacity_units: 3,
      #         write_capacity_units: 1
      #       }
      #     }
      #   )
      #
      # @param [Hash] opts options to pass on to the client call to
      #  +#create_table+. See the documentation above in the AWS SDK for Ruby
      #  V2.
      # @option opts [Hash] :provisioned_throughput This is a required argument,
      #  in which you must specify the +:read_capacity_units+ and
      #  +:write_capacity_units+ of your new table.
      # @option opts [Hash] :global_secondary_index_throughput This argument is
      #  required if you define any global secondary indexes. It should map your
      #  global secondary index names to their provisioned throughput, similar
      #  to how you define the provisioned throughput for the table in general.
      def create!(opts)
        gsit = opts.delete(:global_secondary_index_throughput)
        create_opts = opts.merge({
          table_name: @model.table_name,
          attribute_definitions: _attribute_definitions,
          key_schema: _key_schema
        })
        if lsis = @model.local_secondary_indexes_for_migration
          create_opts[:local_secondary_indexes] = lsis
          _append_to_attribute_definitions(lsis, create_opts)
        end
        if gsis = @model.global_secondary_indexes_for_migration
          unless gsit
            raise ArgumentError.new(
              "If you define global secondary indexes, you must also define"\
                " :global_secondary_index_throughput on table creation."
            )
          end
          gsis_with_throughput = _add_throughout_to_gsis(gsis, gsit)
          create_opts[:global_secondary_indexes] = gsis_with_throughput
          _append_to_attribute_definitions(gsis, create_opts)
        end
        @client.create_table(create_opts)
      end

      # This method calls
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#update_table-instance_method Aws::DynamoDB::Client#update_table}
      # using the parameters that you provide.
      #
      # @param [Hash] opts options to pass on to the client call to
      #  +#update_table+. See the documentation above in the AWS SDK for Ruby
      #  V2.
      # @raise [Aws::Record::Errors::TableDoesNotExist] if the table does not
      #  currently exist in Amazon DynamoDB.
      def update!(opts)
        begin
          update_opts = opts.merge({
            table_name: @model.table_name
          })
          @client.update_table(update_opts)
        rescue DynamoDB::Errors::ResourceNotFoundException => e
          raise Errors::TableDoesNotExist.new(e)
        end
      end

      # This method calls
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#delete_table-instance_method Aws::DynamoDB::Client#delete_table}
      # using the table name of your model.
      #
      # @raise [Aws::Record::Errors::TableDoesNotExist] if the table did not
      #  exist in Amazon DynamoDB at the time of calling.
      def delete!
        begin
          @client.delete_table(table_name: @model.table_name)
        rescue DynamoDB::Errors::ResourceNotFoundException => e
          raise Errors::TableDoesNotExist.new(e)
        end
      end

      # This method waits on the table specified in the model to exist and be
      # marked as ACTIVE in Amazon DynamoDB. Note that this method can run for
      # several minutes if the table does not exist, and is not created within
      # the wait period.
      def wait_until_available
        @client.wait_until(:table_exists, table_name: @model.table_name)
      end

      private
      def _assert_model_valid(model)
        _assert_required_include(model)
        model.model_valid?
      end

      def _assert_required_include(model)
        unless model.include?(::Aws::Record)
          raise Errors::InvalidModel.new("Table models must include Aws::Record")
        end
      end

      def _attribute_definitions
        _keys.map do |type, attr|
          {
            attribute_name: attr.database_name,
            attribute_type: attr.dynamodb_type
          }
        end
      end

      def _append_to_attribute_definitions(secondary_indexes, create_opts)
        attributes = @model.attributes
        attr_def = create_opts[:attribute_definitions]
        secondary_indexes.each do |si|
          si[:key_schema].each do |key_schema|
            exists = attr_def.find { |a|
              a[:attribute_name] == key_schema[:attribute_name]
            }
            unless exists
              attr = attributes.attribute_for(
                attributes.db_to_attribute_name(key_schema[:attribute_name])
              )
              attr_def << {
                attribute_name: attr.database_name,
                attribute_type: attr.dynamodb_type
              }
            end
          end
        end
        create_opts[:attribute_definitions] = attr_def
      end

      def _add_throughout_to_gsis(global_secondary_indexes, gsi_throughput)
        missing_throughput = []
        ret = global_secondary_indexes.map do |params|
          name = params[:index_name]
          throughput = gsi_throughput[name]
          missing_throughput << name unless throughput
          params.merge(provisioned_throughput: throughput)
        end
        unless missing_throughput.empty?
          raise ArgumentError.new(
            "Missing provisioned throughput for the following global secondary"\
              " indexes: #{missing_throughput.join(", ")}. GSIs:"\
              " #{global_secondary_indexes} and defined throughput:"\
              " #{gsi_throughput}"
          )
        end
        ret
      end

      def _key_schema
        _keys.map do |type, attr|
          {
            attribute_name: attr.database_name,
            key_type: type == :hash ? "HASH" : "RANGE"
          }
        end
      end

      def _keys
        @model.keys.inject({}) do |acc, (type, name)|
          acc[type] = @model.attributes.attribute_for(name)
          acc
        end
      end
    end
  end
end
