# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

require 'time'

module Aws
  module Record
    module Marshalers

      class EpochTimeMarshaler
        def initialize(opts = {})
          @use_local_time = opts[:use_local_time] ? true : false
        end

        def type_cast(raw_value)
          value = _format(raw_value)
          if !@use_local_time && value.is_a?(::Time)
            value.utc
          else
            value
          end
        end

        def serialize(raw_value)
          time = type_cast(raw_value)
          if time.nil?
            nil
          elsif time.is_a?(::Time)
            time.to_i
          else
            msg = "expected a Time value or nil, got #{time.class}"
            raise ArgumentError, msg
          end
        end

        private

        def _format(raw_value)
          case raw_value
          when nil
            nil
          when ''
            nil
          when ::Time
            raw_value
          when Integer # timestamp
            ::Time.at(raw_value)
          when BigDecimal
            ::Time.at(raw_value)
          else # Date, DateTime, or String
            ::Time.parse(raw_value.to_s)
          end
        end
      end

    end
  end
end
