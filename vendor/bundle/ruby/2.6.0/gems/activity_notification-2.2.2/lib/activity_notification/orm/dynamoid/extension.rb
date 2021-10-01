require 'dynamoid/adapter_plugin/aws_sdk_v3'

# Entend Dynamoid v3.1.0 to support none, limit, exists?, update_all, serializable_hash in Dynamoid::Criteria::Chain.
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
      # Return new none object
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

      # Return serializable_hash as array
      def serializable_hash(options = {})
        all.to_a.map { |r| r.serializable_hash(options) }
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

# Entend Dynamoid to support uniqueness validator
# @private
module Dynamoid # :nodoc: all
  # https://github.com/Dynamoid/dynamoid/blob/master/lib/dynamoid/validations.rb
  # @private
  module Validations
    # Validates whether or not a field is unique against the records in the database.
    class UniquenessValidator < ActiveModel::EachValidator
      # Validate the document for uniqueness violations.
      # @param [Document] document The document to validate.
      # @param [Symbol] attribute  The name of the attribute.
      # @param [Object] value      The value of the object.
      def validate_each(document, attribute, value)
        return unless validation_required?(document, attribute)
        document.errors.add(attribute, :taken, options.except(:scope).merge(value: value)) if not_unique?(document, attribute, value)
      end

      private

      # Are we required to validate the document?
      # @api private
      def validation_required?(document, attribute)
        document.new_record? ||
          document.send("attribute_changed?", attribute.to_s) ||
          scope_value_changed?(document)
      end

      # Scope reference has changed?
      # @api private
      def scope_value_changed?(document)
        Array.wrap(options[:scope]).any? do |item|
          document.send("attribute_changed?", item.to_s)
        end
      end

      # Check whether a record is uniqueness.
      # @api private
      def not_unique?(document, attribute, value)
        klass = document.class
        while klass.superclass.respond_to?(:validators) && klass.superclass.validators.include?(self)
          klass = klass.superclass
        end
        criteria = create_criteria(klass, document, attribute, value)
        criteria.exists?
      end

      # Create the validation criteria.
      # @api private
      def create_criteria(base, document, attribute, value)
        criteria = scope(base, document)
        filter_criteria(criteria, document, attribute)
      end

      # Scope the criteria to the scope options provided.
      # @api private
      def scope(criteria, document)
        Array.wrap(options[:scope]).each do |item|
          criteria = filter_criteria(criteria, document, item)
        end
        criteria
      end

      # Filter the criteria.
      # @api private
      def filter_criteria(criteria, document, attribute)
        value = document.read_attribute(attribute)
        value.nil? ? criteria.where("#{attribute}.null" => true) : criteria.where(attribute => value)
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
