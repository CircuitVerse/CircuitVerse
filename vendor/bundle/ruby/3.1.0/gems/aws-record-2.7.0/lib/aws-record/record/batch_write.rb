# Copyright 2015-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
    class BatchWrite
      # @param [Aws::DynamoDB::Client] client the DynamoDB SDK client.
      def initialize(client:)
        @client = client
      end

      # Append a +PutItem+ operation to a batch write request.
      #
      # @param [Aws::Record] record a model class that includes {Aws::Record}.
      def put(record)
        table_name, params = record_put_params(record)
        operations[table_name] ||= []
        operations[table_name] << { put_request: params }
      end

      # Append a +DeleteItem+ operation to a batch write request.
      #
      # @param [Aws::Record] record a model class that includes {Aws::Record}.
      def delete(record)
        table_name, params = record_delete_params(record)
        operations[table_name] ||= []
        operations[table_name] << { delete_request: params }
      end

      # Perform a +batch_write_item+ request.
      #
      # @return [Aws::Record::BatchWrite] an instance that provides access to
      #   unprocessed items and allows for retries.
      def execute!
        result = @client.batch_write_item(request_items: operations)
        @operations = result.unprocessed_items
        self
      end

      # Indicates if all items have been processed.
      #
      # @return [Boolean] +true+ if +unprocessed_items+ is empty, +false+
      #   otherwise
      def complete?
        unprocessed_items.values.none?
      end

      # Returns all +DeleteItem+ and +PutItem+ operations that have not yet been
      # processed successfully.
      #
      # @return [Hash] All operations that have not yet successfully completed.
      def unprocessed_items
        operations
      end

      private

      def operations
        @operations ||= {}
      end

      def record_delete_params(record)
        [record.class.table_name, { key: record.key_values }]
      end

      def record_put_params(record)
        [record.class.table_name, { item: record.save_values }]
      end
    end
  end
end
