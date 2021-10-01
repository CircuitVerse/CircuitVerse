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

require 'aws-sdk-dynamodb'
require_relative 'aws-record/record'
require_relative 'aws-record/record/attribute'
require_relative 'aws-record/record/attributes'
require_relative 'aws-record/record/dirty_tracking'
require_relative 'aws-record/record/errors'
require_relative 'aws-record/record/item_collection'
require_relative 'aws-record/record/item_data'
require_relative 'aws-record/record/item_operations'
require_relative 'aws-record/record/key_attributes'
require_relative 'aws-record/record/model_attributes'
require_relative 'aws-record/record/query'
require_relative 'aws-record/record/secondary_indexes'
require_relative 'aws-record/record/table_config'
require_relative 'aws-record/record/table_migration'
require_relative 'aws-record/record/version'
require_relative 'aws-record/record/transactions'
require_relative 'aws-record/record/buildable_search'
require_relative 'aws-record/record/marshalers/string_marshaler'
require_relative 'aws-record/record/marshalers/boolean_marshaler'
require_relative 'aws-record/record/marshalers/integer_marshaler'
require_relative 'aws-record/record/marshalers/float_marshaler'
require_relative 'aws-record/record/marshalers/date_marshaler'
require_relative 'aws-record/record/marshalers/date_time_marshaler'
require_relative 'aws-record/record/marshalers/time_marshaler'
require_relative 'aws-record/record/marshalers/epoch_time_marshaler'
require_relative 'aws-record/record/marshalers/list_marshaler'
require_relative 'aws-record/record/marshalers/map_marshaler'
require_relative 'aws-record/record/marshalers/string_set_marshaler'
require_relative 'aws-record/record/marshalers/numeric_set_marshaler'

module Aws
  module Record
  end
end
