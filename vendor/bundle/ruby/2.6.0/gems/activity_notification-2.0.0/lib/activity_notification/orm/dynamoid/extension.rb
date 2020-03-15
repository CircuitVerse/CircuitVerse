require 'dynamoid/adapter_plugin/aws_sdk_v3'

# Entend Dynamoid to support none, limit, exists?, update_all in Dynamoid::Criteria::Chain.
# ActivityNotification project will try to contribute these fundamental functions to Dynamoid upstream.
# @private
module Dynamoid # :nodoc: all
  # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/criteria.rb
  # @private
  module Criteria
    # @private
    class None < Chain
      def ==(other)
        other.is_a?(None)
      end

      def records
        []
      end

      def count
        0
      end

      def delete_all
      end

      def empty?
        true
      end
    end

    # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/criteria/chain.rb
    # @private
    class Chain
      def none
        None.new(self.source)
      end

      # Set query result limit as record_limit of Dynamoid
      # @scope class
      # @param [Integer] limit Query result limit as record_limit
      # @return [Dynamoid::Criteria::Chain] Database query of filtered notifications or subscriptions
      def limit(limit)
        record_limit(limit)
      end

      # Return if records exist
      # @scope class
      # @return [Boolean] If records exist
      def exists?
        record_limit(1).count > 0
      end

      # Return size of records as count
      # @scope class
      # @return [Integer] Size of records
      def size
        count
      end

      #TODO Make this batch
      def update_all(conditions = {})
        each do |document|
          document.update_attributes(conditions)
        end
      end
    end

    # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/criteria.rb
    # @private
    module ClassMethods
      define_method(:none) do |*args, &blk|
        chain = Dynamoid::Criteria::Chain.new(self)
        chain.send(:none, *args, &blk)
      end
    end
  end
end

# Entend Dynamoid to support query and scan with 'null' and 'not_null' conditions
# @private
module Dynamoid # :nodoc: all
  # @private
  module Criteria
    # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/criteria/chain.rb
    # @private
    module NullOperatorExtension
      # @private
      def field_hash(key)
        name, operation = key.to_s.split('.')
        val = type_cast_condition_parameter(name, query[key])

        hash = case operation
               when 'null'
                 { null: val }
               when 'not_null'
                 { not_null: val }
               else
                 return super(key)
               end

        { name.to_sym => hash }
      end
    end

    # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/criteria/chain.rb
    # @private
    class Chain
      prepend NullOperatorExtension
    end
  end

  # @private
  module AdapterPlugin
    # @private
    class AwsSdkV3

      NULL_OPERATOR_FIELD_MAP = {
        null:         'NULL',
        not_null:     'NOT_NULL'
      }.freeze

      # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/adapter_plugin/aws_sdk_v3/query.rb
      # @private
      class Query < ::Dynamoid::AdapterPlugin::Query
        # @private
        def query_filter
          conditions.except(*AwsSdkV3::RANGE_MAP.keys).reduce({}) do |result, (attr, cond)|
            if AwsSdkV3::NULL_OPERATOR_FIELD_MAP.has_key?(cond.keys[0])
              condition = { comparison_operator: AwsSdkV3::NULL_OPERATOR_FIELD_MAP[cond.keys[0]] }
            else
              condition = {
                comparison_operator: AwsSdkV3::FIELD_MAP[cond.keys[0]],
                attribute_value_list: AwsSdkV3.attribute_value_list(AwsSdkV3::FIELD_MAP[cond.keys[0]], cond.values[0].freeze)
              }
            end
            result[attr] = condition
            result
          end
        end
      end

      # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/adapter_plugin/aws_sdk_v3/scan.rb
      # @private
      class Scan < ::Dynamoid::AdapterPlugin::Scan
        # @private
        def scan_filter
          conditions.reduce({}) do |result, (attr, cond)|
            if AwsSdkV3::NULL_OPERATOR_FIELD_MAP.has_key?(cond.keys[0])
              condition = { comparison_operator: AwsSdkV3::NULL_OPERATOR_FIELD_MAP[cond.keys[0]] }
            else
              condition = {
                comparison_operator: AwsSdkV3::FIELD_MAP[cond.keys[0]],
                attribute_value_list: AwsSdkV3.attribute_value_list(AwsSdkV3::FIELD_MAP[cond.keys[0]], cond.values[0].freeze)
              }
            end
            result[attr] = condition
            result
          end
        end
      end
    end
  end
end

module ActivityNotification
  # Dynamoid extension module for ActivityNotification.
  module DynamoidExtension
    extend ActiveSupport::Concern

    class_methods do
      # Defines delete_all method as calling delete_table and create_table methods
      def delete_all
        delete_table
        create_table(sync: true)
      end
    end

    # Returns an instance of the specified +klass+ with the attributes of the current record.
    def becomes(klass)
      self
    end
  end
end
