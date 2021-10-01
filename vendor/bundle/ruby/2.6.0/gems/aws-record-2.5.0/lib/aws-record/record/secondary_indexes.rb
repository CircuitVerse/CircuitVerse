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
    module SecondaryIndexes

      # @api private
      def self.included(sub_class)
        sub_class.instance_variable_set("@local_secondary_indexes", {})
        sub_class.instance_variable_set("@global_secondary_indexes", {})
        sub_class.extend(SecondaryIndexesClassMethods)
      end

      module SecondaryIndexesClassMethods

        # Creates a local secondary index for the model. Learn more about Local
        # Secondary Indexes in the
        # {http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.html Amazon DynamoDB Developer Guide}.
        #
        # @param [Symbol] name index name for this local secondary index
        # @param [Hash] opts
        # @option opts [Symbol] :range_key the range key used by this local
        #   secondary index. Note that the hash key MUST be the table's hash
        #   key, and so that value will be filled in for you.
        # @option opts [Hash] :projection a hash which defines which attributes
        #   are copied from the table to the index. See shape details in the
        #   {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/Projection.html AWS SDK for Ruby V2 docs}.
        def local_secondary_index(name, opts)
          opts[:hash_key] = hash_key
          _validate_required_lsi_keys(opts)
          local_secondary_indexes[name] = opts
        end

        # Creates a global secondary index for the model. Learn more about
        # Global Secondary Indexes in the
        # {http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html Amazon DynamoDB Developer Guide}.
        #
        # @param [Symbol] name index name for this global secondary index
        # @param [Hash] opts
        # @option opts [Symbol] :hash_key the hash key used by this global
        #   secondary index.
        # @option opts [Symbol] :range_key the range key used by this global
        #   secondary index.
        # @option opts [Hash] :projection a hash which defines which attributes
        #   are copied from the table to the index. See shape details in the
        #   {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Types/Projection.html AWS SDK for Ruby V2 docs}.
        def global_secondary_index(name, opts)
          _validate_required_gsi_keys(opts)
          global_secondary_indexes[name] = opts
        end

        # @return [Hash] hash of local secondary index names to the index's
        #   attributes.
        def local_secondary_indexes
          @local_secondary_indexes
        end

        # @return [Hash] hash of global secondary index names to the index's
        #   attributes.
        def global_secondary_indexes
          @global_secondary_indexes
        end

        # @return [Hash] hash of the local secondary indexes in a form suitable
        #   for use in a table migration. For example, any attributes which
        #   have a unique database storage name will use that name instead.
        def local_secondary_indexes_for_migration
          _migration_format_indexes(local_secondary_indexes)
        end

        # @return [Hash] hash of the global secondary indexes in a form suitable
        #   for use in a table migration. For example, any attributes which
        #   have a unique database storage name will use that name instead.
        def global_secondary_indexes_for_migration
          _migration_format_indexes(global_secondary_indexes)
        end

        private
        def _migration_format_indexes(indexes)
          return nil if indexes.empty?
          mfi = indexes.collect do |name, opts|
            h = { index_name: name }
            h[:key_schema] = _si_key_schema(opts)
            hk = opts.delete(:hash_key)
            rk = opts.delete(:range_key)
            h = h.merge(opts)
            opts[:hash_key] = hk if hk
            opts[:range_key] = rk if rk
            h
          end
          mfi
        end

        def _si_key_schema(opts)
          key_schema = [{
            key_type: "HASH",
            attribute_name: @attributes.storage_name_for(opts[:hash_key])
          }]
          if opts[:range_key]
            key_schema << {
              key_type: "RANGE",
              attribute_name: @attributes.storage_name_for(opts[:range_key])
            }
          end
          key_schema
        end

        def _validate_required_lsi_keys(params)
          if params[:hash_key] && params[:range_key]
            _validate_attributes_exist(params[:hash_key], params[:range_key])
          else
            raise ArgumentError.new(
              "Local Secondary Indexes require a hash and range key!"
            )
          end
        end

        def _validate_required_gsi_keys(params)
          if params[:hash_key]
            if params[:range_key]
              _validate_attributes_exist(params[:hash_key], params[:range_key])
            else
              _validate_attributes_exist(params[:hash_key])
            end
          else
            raise ArgumentError.new(
              "Global Secondary Indexes require at least a hash key!"
            )
          end
        end

        def _validate_attributes_exist(*attr_names)
          missing = attr_names.select do |attr_name|
            !@attributes.present?(attr_name)
          end
          unless missing.empty?
            raise ArgumentError.new(
              "#{missing.join(", ")} not present in model attributes."\
                " Please ensure that attributes are defined in the model"\
                " class BEFORE defining an index on those attributes."
            )
          end
        end
      end

    end
  end
end
