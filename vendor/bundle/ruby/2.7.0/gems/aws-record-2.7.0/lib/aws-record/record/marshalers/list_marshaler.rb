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

      class ListMarshaler
        def initialize(opts = {})
        end

        def type_cast(raw_value)
          case raw_value
          when nil
            nil
          when ''
            nil
          when Array
            raw_value
          else
            if raw_value.respond_to?(:to_a)
              raw_value.to_a
            else
              msg = "Don't know how to make #{raw_value} of type"\
                " #{raw_value.class} into an array!"
              raise ArgumentError, msg
            end
          end
        end

        def serialize(raw_value)
          list = type_cast(raw_value)
          if list.is_a?(Array)
            list
          elsif list.nil?
            nil
          else
            msg = "expected an Array value or nil, got #{list.class}"
            raise ArgumentError, msg
          end
        end
      end

    end
  end
end
