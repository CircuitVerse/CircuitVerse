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

    # @api private
    class KeyAttributes
      attr_reader :keys

      def initialize(model_attributes)
        @keys = {}
        @model_attributes = model_attributes
      end

      def hash_key
        @hash_key
      end

      def hash_key_attribute
        @model_attributes.attribute_for(hash_key)
      end

      def range_key
        @range_key
      end

      def range_key_attribute
        @model_attributes.attribute_for(range_key)
      end

      def hash_key=(value)
        @keys[:hash] = value
        @hash_key = value
      end

      def range_key=(value)
        @keys[:range] = value
        @range_key = value
      end
    end

  end
end
