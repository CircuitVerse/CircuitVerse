# Copyright 2015-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

    # +Aws::Record::TableConfig+ provides a DSL for describing and modifying
    # the remote configuration of your DynamoDB tables. A table configuration
    # object can perform intelligent comparisons and incremental migrations
    # versus the current remote configuration, if the table exists, or do a full
    # create if it does not. In this manner, table configuration becomes fully
    # declarative.
    #
    # @example A basic model with configuration.
    #   class Model
    #     include Aws::Record
    #     string_attr :uuid, hash_key: true
    #   end
    #
    #   table_config = Aws::Record::TableConfig.define do |t|
    #     t.model_class Model
    #     t.read_capacity_units 10
    #     t.write_capacity_units 5
    #   end
    #
    # @example A basic model with pay per request billing.
    #   class Model
    #     include Aws::Record
    #     string_attr :uuid, hash_key: true
    #   end
    #
    #   table_config = Aws::Record::TableConfig.define do |t|
    #     t.model_class Model
    #     t.billing_mode "PAY_PER_REQUEST"
    #   end
    #
    # @example Running a conditional migration on a basic model.
    #   table_config = Aws::Record::TableConfig.define do |t|
    #     t.model_class Model
    #     t.read_capacity_units 10
    #     t.write_capacity_units 5
    #   end
    #
    #   table_config.migrate! unless table_config.compatible?
    #
    # @example A model with a global secondary index.
    #   class Forum
    #     include Aws::Record
    #     string_attr     :forum_uuid, hash_key: true
    #     integer_attr    :post_id,    range_key: true
    #     string_attr     :post_title
    #     string_attr     :post_body
    #     string_attr     :author_username
    #     datetime_attr   :created_date
    #     datetime_attr   :updated_date
    #     string_set_attr :tags
    #     map_attr        :metadata, default_value: {}
    #
    #     global_secondary_index(
    #       :title,
    #       hash_key:  :forum_uuid,
    #       range_key: :post_title,
    #       projection: {
    #         projection_type: "ALL"
    #       }
    #     )
    #   end
    #
    #   table_config = Aws::Record::TableConfig.define do |t|
    #     t.model_class Forum
    #     t.read_capacity_units 10
    #     t.write_capacity_units 5
    #
    #     t.global_secondary_index(:title) do |i|
    #       i.read_capacity_units 5
    #       i.write_capacity_units 5
    #     end
    #   end
    #
    # @example A model with a Time to Live attribute
    #   class ExpiringTokens
    #     string_attr :token_uuid, hash_key: true
    #     epoch_time_attr :ttl
    #   end
    #
    #   table_config = Aws::Record::TableConfig.define do |t|
    #     t.model_class ExpiringTokens
    #     t.read_capacity_units 10
    #     t.write_capacity_units 1
    #     t.ttl_attribute :ttl
    #   end
    #
    class TableConfig

      attr_accessor :client

      class << self

        # Creates a new table configuration, using a DSL in the provided block.
        # The DSL has the following methods:
        # * +#model_class+ A class name reference to the +Aws::Record+ model
        #   class.
        # * +#read_capacity_units+ Sets the read capacity units for the table.
        # * +#write_capacity_units+ Sets the write capacity units for the table.
        # * +#global_secondary_index(index_symbol, &block)+ Defines a global
        #   secondary index with capacity attributes in a block:
        #   * +#read_capacity_units+ Sets the read capacity units for the
        #     index.
        #   * +#write_capacity_units+ Sets the write capacity units for the
        #     index.
        # * +#ttl_attribute+ Sets the attribute ID to be used as the TTL
        #   attribute, and if present, TTL will be enabled for the table.
        # * +#billing_mode+ Sets the billing mode, with the current supported
        #   options being "PROVISIONED" and "PAY_PER_REQUEST". If using
        #   "PAY_PER_REQUEST" you must not set provisioned throughput values,
        #   and if using "PROVISIONED" you must set provisioned throughput
        #   values. Default assumption is "PROVISIONED".
        #
        # @example Defining a migration with a GSI.
        #   class Forum
        #     include Aws::Record
        #     string_attr     :forum_uuid, hash_key: true
        #     integer_attr    :post_id,    range_key: true
        #     string_attr     :post_title
        #     string_attr     :post_body
        #     string_attr     :author_username
        #     datetime_attr   :created_date
        #     datetime_attr   :updated_date
        #     string_set_attr :tags
        #     map_attr        :metadata, default_value: {}
        #
        #     global_secondary_index(
        #       :title,
        #       hash_key:  :forum_uuid,
        #       range_key: :post_title,
        #       projection_type: "ALL"
        #     )
        #   end
        #
        #   table_config = Aws::Record::TableConfig.define do |t|
        #     t.model_class Forum
        #     t.read_capacity_units 10
        #     t.write_capacity_units 5
        #
        #     t.global_secondary_index(:title) do |i|
        #       i.read_capacity_units 5
        #       i.write_capacity_units 5
        #     end
        #   end
        def define(&block)
          cfg = TableConfig.new
          cfg.instance_eval(&block)
          cfg.configure_client
          cfg
        end
      end

      # @api private
      def initialize
        @client_options = {}
        @global_secondary_indexes = {}
        @billing_mode = "PROVISIONED" # default
      end

      # @api private
      def model_class(model)
        @model_class = model
      end

      # @api private
      def read_capacity_units(units)
        @read_capacity_units = units
      end

      # @api private
      def write_capacity_units(units)
        @write_capacity_units = units
      end

      # @api private
      def global_secondary_index(name, &block)
        gsi = GlobalSecondaryIndex.new
        gsi.instance_eval(&block)
        @global_secondary_indexes[name] = gsi
      end

      # @api private
      def client_options(opts)
        @client_options = opts
      end

      # @api private
      def configure_client
        @client = Aws::DynamoDB::Client.new(@client_options)
      end

      # @api private
      def ttl_attribute(attribute_symbol)
        attribute = @model_class.attributes.attribute_for(attribute_symbol)
        if attribute
          @ttl_attribute = attribute.database_name
        else
          raise ArgumentError, "Invalid attribute #{attribute_symbol} for #{@model_class}"
        end
      end

      # @api private
      def billing_mode(mode)
        @billing_mode = mode
      end

      # Performs a migration, if needed, against the remote table. If
      # +#compatible?+ would return true, the remote table already has the same
      # throughput, key schema, attribute definitions, and global secondary
      # indexes, so no further API calls are made. Otherwise, a DynamoDB table
      # will be created or updated to match your declared configuration.
      def migrate!
        _validate_required_configuration
        begin
          resp = @client.describe_table(table_name: @model_class.table_name)
          if _compatible_check(resp)
            nil
          else
            # Gotcha: You need separate migrations for indexes and throughput
            unless _throughput_equal(resp)
              @client.update_table(_update_throughput_opts(resp))
              @client.wait_until(
                :table_exists,
                table_name: @model_class.table_name
              )
            end
            unless _gsi_superset(resp)
              @client.update_table(_update_index_opts(resp))
              @client.wait_until(
              :table_exists,
              table_name: @model_class.table_name
            )
            end
          end
        rescue DynamoDB::Errors::ResourceNotFoundException
          # Code Smell: Exception as control flow.
          # Can I use SDK ability to skip raising an exception for this?
          @client.create_table(_create_table_opts)
          @client.wait_until(:table_exists, table_name: @model_class.table_name)
        end
        # At this stage, we have a table and need to check for after-effects to
        # apply.
        # First up is TTL attribute. Since this migration is not exact match,
        # we will only alter TTL status if we have a TTL attribute defined. We
        # may someday support explicit TTL deletion, but we do not yet do this.
        if @ttl_attribute
          if !_ttl_compatibility_check
            client.update_time_to_live(
              table_name: @model_class.table_name,
              time_to_live_specification: {
                enabled: true,
                attribute_name: @ttl_attribute
              }
            )
          end # Else TTL is compatible and we are done.
        end # Else our work is done.
      end

      # Checks the remote table for compatibility. Similar to +#exact_match?+,
      # this will return +false+ if the remote table does not exist. It also
      # checks the keys, declared global secondary indexes, declared attribute
      # definitions, and throughput for exact matches. However, if the remote
      # end has additional attribute definitions and global secondary indexes
      # not defined in your config, will still return +true+. This allows for a
      # check that is friendly to single table inheritance use cases.
      #
      # @return [Boolean] true if remote is compatible, false otherwise.
      def compatible?
        begin
          resp = @client.describe_table(table_name: @model_class.table_name)
          _compatible_check(resp) && _ttl_compatibility_check
        rescue DynamoDB::Errors::ResourceNotFoundException
          false
        end
      end

      # Checks against the remote table's configuration. If the remote table
      # does not exist, guaranteed +false+. Otherwise, will check if the remote
      # throughput, keys, attribute definitions, and global secondary indexes
      # are exactly equal to your declared configuration.
      #
      # @return [Boolean] true if remote is an exact match, false otherwise.
      def exact_match?
        begin
          resp = @client.describe_table(table_name: @model_class.table_name)
          _throughput_equal(resp) &&
            _keys_equal(resp) &&
            _ad_equal(resp) &&
            _gsi_equal(resp) &&
            _ttl_match_check
        rescue DynamoDB::Errors::ResourceNotFoundException
          false
        end
      end

      private
      def _ttl_compatibility_check
        if @ttl_attribute
          ttl_status = @client.describe_time_to_live(
            table_name: @model_class.table_name
          )
          desc = ttl_status.time_to_live_description
          ["ENABLED", "ENABLING"].include?(desc.time_to_live_status) &&
            desc.attribute_name == @ttl_attribute
        else
          true
        end
      end

      def _ttl_match_check
        ttl_status = @client.describe_time_to_live(
          table_name: @model_class.table_name
        )
        desc = ttl_status.time_to_live_description
        if @ttl_attribute
          ["ENABLED", "ENABLING"].include?(desc.time_to_live_status) &&
            desc.attribute_name == @ttl_attribute
        else
          !["ENABLED", "ENABLING"].include?(desc.time_to_live_status) ||
            desc.attribute_name == nil
        end
      end

      def _compatible_check(resp)
        _throughput_equal(resp) &&
          _keys_equal(resp) &&
          _ad_superset(resp) &&
          _gsi_superset(resp)
      end

      def _create_table_opts
        opts = {
          table_name: @model_class.table_name
        }
        if @billing_mode == "PROVISIONED"
          opts[:provisioned_throughput] = {
            read_capacity_units: @read_capacity_units,
            write_capacity_units: @write_capacity_units
          }
        elsif @billing_mode == "PAY_PER_REQUEST"
          opts[:billing_mode] = @billing_mode
        else
          raise ArgumentError, "Unsupported billing mode #{@billing_mode}"
        end
          
        opts[:key_schema] = _key_schema
        opts[:attribute_definitions] = _attribute_definitions
        gsi = _global_secondary_indexes
        unless gsi.empty?
          opts[:global_secondary_indexes] = gsi 
        end
        opts
      end

      def _add_global_secondary_index_throughput(opts, resp_gsis)
        gsis = resp_gsis.map do |g|
          g.index_name
        end
        gsi_updates = []
        gsis.each do |index_name|
          lgsi = @global_secondary_indexes[index_name.to_sym]
          gsi_updates << {
            update: {
              index_name: index_name,
              provisioned_throughput: lgsi.provisioned_throughput
            }
          }
        end
        opts[:global_secondary_index_updates] = gsi_updates
        true
      end

      def _update_throughput_opts(resp)
        if @billing_mode == "PROVISIONED"
          opts = {
            table_name: @model_class.table_name,
            provisioned_throughput: {
              read_capacity_units: @read_capacity_units,
              write_capacity_units: @write_capacity_units
            }
          }
          # special case: we have global secondary indexes existing, and they
          # need provisioned capacity to be set within this call
          if !resp.table.billing_mode_summary.nil? &&
              resp.table.billing_mode_summary.billing_mode == "PAY_PER_REQUEST"
            opts[:billing_mode] = @billing_mode
            if resp.table.global_secondary_indexes
              resp_gsis = resp.table.global_secondary_indexes
              _add_global_secondary_index_throughput(opts, resp_gsis)
            end
          end # else don't include billing mode
          opts
        elsif @billing_mode == "PAY_PER_REQUEST"
          {
            table_name: @model_class.table_name,
            billing_mode: "PAY_PER_REQUEST"
          }
        else
          raise ArgumentError, "Unsupported billing mode #{@billing_mode}"
        end
      end

      def _update_index_opts(resp)
        gsi_updates, attribute_definitions = _gsi_updates(resp)
        opts = {
          table_name: @model_class.table_name,
          global_secondary_index_updates: gsi_updates
        }
        unless attribute_definitions.empty?
          opts[:attribute_definitions] = attribute_definitions
        end
        opts
      end

      def _gsi_updates(resp)
        gsi_updates = []
        attributes_referenced = Set.new
        remote_gsis = resp.table.global_secondary_indexes
        local_gsis = _global_secondary_indexes
        remote_idx, local_idx = _gsi_index_names(remote_gsis, local_gsis)
        create_candidates = local_idx - remote_idx
        update_candidates = local_idx.intersection(remote_idx)
        create_candidates.each do |index_name|
          gsi = @model_class.global_secondary_indexes_for_migration.find do |i|
            i[:index_name].to_s == index_name
          end
          gsi[:key_schema].each do |k|
            attributes_referenced.add(k[:attribute_name])
          end
          if @billing_mode == "PROVISIONED"
            lgsi = @global_secondary_indexes[index_name.to_sym]
            gsi[:provisioned_throughput] = lgsi.provisioned_throughput
          end
          gsi_updates << {
            create: gsi
          }
        end
        # we don't currently update anything other than throughput
        if @billing_mode == "PROVISIONED"
          update_candidates.each do |index_name|
            lgsi = @global_secondary_indexes[index_name.to_sym]
            gsi_updates << {
              update: {
                index_name: index_name,
                provisioned_throughput: lgsi.provisioned_throughput
              }
            }
          end
        end
        attribute_definitions = _attribute_definitions
        incremental_attributes = attributes_referenced.map do |attr_name|
          attribute_definitions.find do |ad|
            ad[:attribute_name] == attr_name
          end
        end
        [gsi_updates, incremental_attributes]
      end

      def _key_schema
        _keys.map do |type, attr|
          {
            attribute_name: attr.database_name,
            key_type: type == :hash ? "HASH" : "RANGE"
          }
        end
      end

      def _attribute_definitions
        attribute_definitions = _keys.map do |type, attr|
          {
            attribute_name: attr.database_name,
            attribute_type: attr.dynamodb_type
          }
        end
        @model_class.global_secondary_indexes.each do |_, attributes|
          gsi_keys = [attributes[:hash_key]]
          gsi_keys << attributes[:range_key] if attributes[:range_key]
          gsi_keys.each do |name|
            attribute = @model_class.attributes.attribute_for(name)
            exists = attribute_definitions.any? do |ad|
              ad[:attribute_name] == attribute.database_name
            end
            unless exists
              attribute_definitions << {
                attribute_name: attribute.database_name,
                attribute_type: attribute.dynamodb_type
              }
            end
          end
        end
        attribute_definitions
      end

      def _keys
        @model_class.keys.inject({}) do |acc, (type, name)|
          acc[type] = @model_class.attributes.attribute_for(name)
          acc
        end
      end

      def _throughput_equal(resp)
        if @billing_mode == "PAY_PER_REQUEST"
          !resp.table.billing_mode_summary.nil? &&
            resp.table.billing_mode_summary.billing_mode == "PAY_PER_REQUEST"
        else
          expected = resp.table.provisioned_throughput.to_h
          actual = {
            read_capacity_units: @read_capacity_units,
            write_capacity_units: @write_capacity_units
          }
          actual.all? do |k,v|
            expected[k] == v
          end
        end
      end

      def _keys_equal(resp)
        remote_key_schema = resp.table.key_schema.map { |i| i.to_h }
        _array_unsorted_eql(remote_key_schema, _key_schema)
      end

      def _ad_equal(resp)
        remote_ad = resp.table.attribute_definitions.map { |i| i.to_h }
        _array_unsorted_eql(remote_ad, _attribute_definitions)
      end

      def _ad_superset(resp)
        remote_ad = resp.table.attribute_definitions.map { |i| i.to_h }
        _attribute_definitions.all? do |attribute_definition|
          remote_ad.include?(attribute_definition)
        end
      end

      def _gsi_superset(resp)
        remote_gsis = resp.table.global_secondary_indexes
        local_gsis = _global_secondary_indexes
        remote_idx, local_idx = _gsi_index_names(remote_gsis, local_gsis)
        if local_idx.subset?(remote_idx)
           _gsi_set_compare(remote_gsis, local_gsis)
        else
          # If we have any local indexes not on the remote table,
          # guaranteed false.
          false
        end
      end

      def _gsi_equal(resp)
        remote_gsis = resp.table.global_secondary_indexes
        local_gsis = _global_secondary_indexes
        remote_idx, local_idx = _gsi_index_names(remote_gsis, local_gsis)
        if local_idx == remote_idx
          _gsi_set_compare(remote_gsis, local_gsis)
        else
          false
        end
      end

      def _gsi_set_compare(remote_gsis, local_gsis)
        local_gsis.all? do |lgsi|
          rgsi = remote_gsis.find do |r|
            r.index_name == lgsi[:index_name].to_s
          end

          remote_key_schema = rgsi.key_schema.map { |i| i.to_h }
          ks_match = _array_unsorted_eql(remote_key_schema, lgsi[:key_schema])

          # Throughput Check: Dependent on Billing Mode
          rpt = rgsi.provisioned_throughput.to_h
          lpt = lgsi[:provisioned_throughput]
          if @billing_mode == "PROVISIONED"
            pt_match = lpt.all? do |k,v|
              rpt[k] == v
            end
          elsif @billing_mode == "PAY_PER_REQUEST"
            pt_match = lpt.nil? ? true : false
          else
            raise ArgumentError, "Unsupported billing mode #{@billing_mode}"
          end

          rp = rgsi.projection.to_h
          lp = lgsi[:projection]
          rp[:non_key_attributes].sort! if rp[:non_key_attributes]
          lp[:non_key_attributes].sort! if lp[:non_key_attributes]
          p_match = rp == lp

          ks_match && pt_match && p_match
        end
      end

      def _gsi_index_names(remote, local)
        remote_index_names = Set.new
        local_index_names = Set.new
        if remote
          remote.each do |gsi|
            remote_index_names.add(gsi.index_name)
          end
        end
        if local
          local.each do |gsi|
            local_index_names.add(gsi[:index_name].to_s)
          end
        end
        [remote_index_names, local_index_names]
      end

      def _global_secondary_indexes
        gsis = []
        model_gsis = @model_class.global_secondary_indexes_for_migration
        gsi_config = @global_secondary_indexes
        if model_gsis
          model_gsis.each do |mgsi|
            config = gsi_config[mgsi[:index_name]]
            if @billing_mode == "PROVISIONED"
              gsis << mgsi.merge(
                provisioned_throughput: config.provisioned_throughput
              )
            else
              gsis << mgsi
            end
          end
        end
        gsis
      end

      def _array_unsorted_eql(a, b)
        a.all? { |x| b.include?(x) } && b.all? { |x| a.include?(x) }
      end

      def _validate_required_configuration
        missing_config = []
        missing_config << 'model_class' unless @model_class
        if @billing_mode == "PROVISIONED"
          missing_config << 'read_capacity_units' unless @read_capacity_units
          missing_config << 'write_capacity_units' unless @write_capacity_units
        else
          if @read_capacity_units || @write_capacity_units
            raise ArgumentError.new("Cannot have billing mode #{@billing_mode} with provisioned capacity.")
          end
        end
        unless missing_config.empty?
          msg = missing_config.join(', ')
          raise Errors::MissingRequiredConfiguration, 'Missing: ' + msg
        end
      end

      # @api private
      class GlobalSecondaryIndex
        attr_reader :provisioned_throughput

        def initialize
          @provisioned_throughput = {}
        end

        def read_capacity_units(units)
          @provisioned_throughput[:read_capacity_units] = units
        end

        def write_capacity_units(units)
          @provisioned_throughput[:write_capacity_units] = units
        end
      end

    end
  end
end
