# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
    module Marshalers

      class FloatMarshaler
        def initialize(opts = {})
        end

        def type_cast(raw_value)
          case raw_value
          when nil
            nil
          when ''
            nil
          when Float
            raw_value
          else
            raw_value.respond_to?(:to_f) ?
              raw_value.to_f :
              raw_value.to_s.to_f
          end
        end

        def serialize(raw_value)
          float = type_cast(raw_value)
          if float.nil?
            nil
          elsif float.is_a?(Float)
            float
          else
            msg = "expected a Float value or nil, got #{float.class}"
            raise ArgumentError, msg
          end
        end
      end

    end
  end
end
