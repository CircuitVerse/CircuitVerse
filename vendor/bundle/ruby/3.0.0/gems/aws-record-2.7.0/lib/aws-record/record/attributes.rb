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
    module Attributes

      def self.included(sub_class)
        sub_class.extend(ClassMethods)
        model_attributes = ModelAttributes.new(self)
        sub_class.instance_variable_set("@attributes", model_attributes)
        sub_class.instance_variable_set("@keys", KeyAttributes.new(model_attributes))
      end

      # @example Usage Example
      #   class MyModel
      #     include Aws::Record
      #     integer_attr :id,   hash_key: true
      #     string_attr  :name, range_key: true
      #     string_attr  :body
      #   end
      #
      #   item = MyModel.new(id: 1, name: "Quick Create")
      #
      # Base initialization method for a new item. Optionally, allows you to
      # provide initial attribute values for the model. You do not need to
      # provide all, or even any, attributes at item creation time.
      #
      # @param [Hash] attr_values Attribute symbol/value pairs for any initial
      #  attribute values you wish to set.
      # @return [Aws::Record] An item instance for your model.
      def initialize(attr_values = {})
        opts = {
          track_mutations: self.class.mutation_tracking_enabled?
        }
        @data = ItemData.new(self.class.attributes, opts)
        attr_values.each do |attr_name, attr_value|
          send("#{attr_name}=", attr_value)
        end
      end

      # Returns a hash representation of the attribute data.
      #
      # @return [Hash] Map of attribute names to raw values.
      def to_h
        @data.hash_copy
      end

      module ClassMethods

        # Define an attribute for your model, providing your own attribute type.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Marshaler] marshaler The marshaler for this attribute. So long
        #   as you provide a marshaler which implements +#type_cast+ and
        #   +#serialize+ that consume raw values as expected, you can bring your
        #   own marshaler type. Convenience methods will provide this for you.
        # @param [Hash] opts
        # @option opts [String] :database_attribute_name Optional attribute
        #   used to specify a different name for database persistence than the
        #   `name` parameter. Must be unique (you can't have overlap between
        #   database attribute names and the names of other attributes).
        # @option opts [String] :dynamodb_type Generally used for keys and
        #   index attributes, one of "S", "N", "B", "BOOL", "SS", "NS", "BS",
        #   "M", "L". Optional if this attribute will never be used for a key or
        #   secondary index, but most convenience methods for setting attributes
        #   will provide this.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        def attr(name, marshaler, opts = {})
          @attributes.register_attribute(name, marshaler, opts)
          _define_attr_methods(name)
          _key_attributes(name, opts)
        end

        # Define a string-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def string_attr(name, opts = {})
          opts[:dynamodb_type] = "S"
          attr(name, Marshalers::StringMarshaler.new(opts), opts)
        end

        # Define a boolean-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def boolean_attr(name, opts = {})
          opts[:dynamodb_type] = "BOOL"
          attr(name, Marshalers::BooleanMarshaler.new(opts), opts)
        end

        # Define a integer-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def integer_attr(name, opts = {})
          opts[:dynamodb_type] = "N"
          attr(name, Marshalers::IntegerMarshaler.new(opts), opts)
        end

        # Define a float-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def float_attr(name, opts = {})
          opts[:dynamodb_type] = "N"
          attr(name, Marshalers::FloatMarshaler.new(opts), opts)
        end

        # Define a date-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option options [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def date_attr(name, opts = {})
          opts[:dynamodb_type] = "S"
          attr(name, Marshalers::DateMarshaler.new(opts), opts)
        end

        # Define a datetime-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def datetime_attr(name, opts = {})
          opts[:dynamodb_type] = "S"
          attr(name, Marshalers::DateTimeMarshaler.new(opts), opts)
        end

        # Define a time-type attribute for your model.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def time_attr(name, opts = {})
          opts[:dynamodb_type] = "S"
          attr(name, Marshalers::TimeMarshaler.new(opts), opts)
        end

        # Define a time-type attribute for your model which persists as
        #   epoch-seconds.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name
        #   that is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Boolean] :persist_nil Optional attribute used to
        #   indicate whether nil values should be persisted. If true, explicitly
        #   set nil values will be saved to DynamoDB as a "null" type. If false,
        #   nil values will be ignored and not persisted. By default, is false.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def epoch_time_attr(name, opts = {})
          opts[:dynamodb_type] = "N"
          attr(name, Marshalers::EpochTimeMarshaler.new(opts), opts)
        end

        # Define a list-type attribute for your model.
        #
        # Lists do not have to be homogeneous, but they do have to be types that
        # the AWS SDK for Ruby V2's DynamoDB client knows how to marshal and
        # unmarshal. Those types are:
        #
        # * Hash
        # * Array
        # * String
        # * Numeric
        # * Boolean
        # * IO
        # * Set
        # * nil
        #
        # Also note that, since lists are heterogeneous, you may lose some
        # precision when marshaling and unmarshaling. For example, symbols will
        # be stringified, but there is no way to return those strings to symbols
        # when the object is read back from DynamoDB.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def list_attr(name, opts = {})
          opts[:dynamodb_type] = "L"
          attr(name, Marshalers::ListMarshaler.new(opts), opts)
        end

        # Define a map-type attribute for your model.
        #
        # Maps do not have to be homogeneous, but they do have to use types that
        # the AWS SDK for Ruby V2's DynamoDB client knows how to marshal and
        # unmarshal. Those types are:
        #
        # * Hash
        # * Array
        # * String
        # * Numeric
        # * Boolean
        # * IO
        # * Set
        # * nil
        #
        # Also note that, since maps are heterogeneous, you may lose some
        # precision when marshaling and unmarshaling. For example, symbols will
        # be stringified, but there is no way to return those strings to symbols
        # when the object is read back from DynamoDB.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def map_attr(name, opts = {})
          opts[:dynamodb_type] = "M"
          attr(name, Marshalers::MapMarshaler.new(opts), opts)
        end

        # Define a string set attribute for your model.
        #
        # String sets are homogeneous sets, containing only strings. Note that
        # empty sets cannot be persisted to DynamoDB. Empty sets are valid for
        # aws-record items, but they will not be persisted as sets. nil values
        # from your table, or a lack of value from your table, will be treated
        # as an empty set for item instances. At persistence time, the marshaler
        # will attempt to marshal any non-strings within the set to be String
        # objects.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def string_set_attr(name, opts = {})
          opts[:dynamodb_type] = "SS"
          attr(name, Marshalers::StringSetMarshaler.new(opts), opts)
        end

        # Define a numeric set attribute for your model.
        #
        # Numeric sets are homogeneous sets, containing only numbers. Note that
        # empty sets cannot be persisted to DynamoDB. Empty sets are valid for
        # aws-record items, but they will not be persisted as sets. nil values
        # from your table, or a lack of value from your table, will be treated
        # as an empty set for item instances. At persistence time, the marshaler
        # will attempt to marshal any non-numerics within the set to be Numeric
        # objects.
        #
        # @param [Symbol] name Name of this attribute.  It should be a name that
        #   is safe to use as a method.
        # @param [Hash] opts
        # @option opts [Boolean] :hash_key Set to true if this attribute is
        #   the hash key for the table.
        # @option opts [Boolean] :range_key Set to true if this attribute is
        #   the range key for the table.
        # @option opts [Object] :default_value Optional attribute used to
        #   define a "default value" to be used if the attribute's value on an
        #   item is nil or not set at persistence time.
        def numeric_set_attr(name, opts = {})
          opts[:dynamodb_type] = "NS"
          attr(name, Marshalers::NumericSetMarshaler.new(opts), opts)
        end

        # @return [Symbol,nil] The symbolic name of the table's hash key.
        def hash_key
          @keys.hash_key
        end

        # @return [Symbol,nil] The symbloc name of the table's range key, or nil if there is no range key.
        def range_key
          @keys.range_key
        end

        # @api private
        def attributes
          @attributes
        end

        # @api private
        def keys
          @keys.keys
        end

        private
        def _define_attr_methods(name)
          define_method(name) do
            @data.get_attribute(name)
          end

          define_method("#{name}=") do |value|
            @data.set_attribute(name, value)
          end
        end

        def _key_attributes(id, opts)
          if opts[:hash_key] == true && opts[:range_key] == true
            raise ArgumentError.new(
              "Cannot have the same attribute be a hash and range key."
            )
          elsif opts[:hash_key] == true
            @keys.hash_key = id
          elsif opts[:range_key] == true
            @keys.range_key = id
          end
        end

      end

    end
  end
end
