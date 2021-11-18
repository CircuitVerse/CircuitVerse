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

    # This class provides helper methods for +Aws::Record+ attributes. These
    # include marshalers for type casting of item attributes, the Amazon
    # DynamoDB type for use in certain table and item operation calls, and the
    # ability to define a database name that is separate from the name used
    # within the model class and item instances.
    class Attribute

      attr_reader :name, :database_name, :dynamodb_type

      # @param [Symbol] name Name of the attribute. It should be a name that is
      #  safe to use as a method.
      # @param [Hash] options
      # @option options [Marshaler] :marshaler The marshaler for this attribute.
      #   So long as you provide a marshaler which implements +#type_cast+ and
      #   +#serialize+ that consume raw values as expected, you can bring your
      #   own marshaler type.
      # @option options [String] :database_attribute_name Optional attribute
      #   used to specify a different name for database persistence than the
      #   `name` parameter. Must be unique (you can't have overlap between
      #   database attribute names and the names of other attributes).
      # @option options [String] :dynamodb_type Generally used for keys and
      #   index attributes, one of "S", "N", "B", "BOOL", "SS", "NS", "BS",
      #   "M", "L". Optional if this attribute will never be used for a key or
      #   secondary index, but most convenience methods for setting attributes
      #   will provide this.
      # @option options [Boolean] :persist_nil Optional attribute used to
      #   indicate whether nil values should be persisted. If true, explicitly
      #   set nil values will be saved to DynamoDB as a "null" type. If false,
      #   nil values will be ignored and not persisted. By default, is false.
      # @option options [Object] :default_value Optional attribute used to
      #   define a "default value" to be used if the attribute's value on an
      #   item is nil or not set at persistence time.
      def initialize(name, options = {})
        @name = name
        @database_name = (options[:database_attribute_name]  || name).to_s
        @dynamodb_type = options[:dynamodb_type]
        @marshaler = options[:marshaler] || DefaultMarshaler
        @persist_nil = options[:persist_nil]
        dv = options[:default_value]
        unless dv.nil?
          @default_value_or_lambda = _is_lambda?(dv) ? dv : type_cast(dv)
        end
      end

      # Attempts to type cast a raw value into the attribute's type. This call
      # will forward the raw value to this attribute's marshaler class.
      #
      # @return [Object] the type cast object. Return type is dependent on the
      #  marshaler used. See your attribute's marshaler class for details.
      def type_cast(raw_value)
        cast_value = @marshaler.type_cast(raw_value)
        cast_value = default_value if cast_value.nil?
        cast_value
      end

      # Attempts to serialize a raw value into the attribute's serialized
      # storage type. This call will forward the raw value to this attribute's
      # marshaler class.
      #
      # @return [Object] the serialized object. Return type is dependent on the
      #  marshaler used. See your attribute's marshaler class for details.
      def serialize(raw_value)
        cast_value = type_cast(raw_value)
        cast_value = default_value if cast_value.nil?
        @marshaler.serialize(cast_value)
      end

      # @return [Boolean] true if this attribute will actively persist nil
      #   values, false otherwise. Default: false
      def persist_nil?
        @persist_nil ? true : false
      end

      # @api private
      def extract(dynamodb_item)
        dynamodb_item[@database_name]
      end

      # @api private
      def default_value
        if _is_lambda?(@default_value_or_lambda)
          type_cast(@default_value_or_lambda.call)
        else
          _deep_copy(@default_value_or_lambda)
        end
      end

      private
      def _deep_copy(obj)
        Marshal.load(Marshal.dump(obj))
      end

      def _is_lambda?(obj)
        obj.respond_to?(:call)
      end

    end

    # This is an identity marshaler, which performs no changes for type casting
    # or serialization. It is generally not recommended for use.
    module DefaultMarshaler
      def self.type_cast(raw_value, options = {})
        raw_value
      end

      def self.serialize(raw_value, options = {})
        raw_value
      end
    end
  end
end
