# frozen_string_literal: true

# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'spec_helper'
require 'stringio'
require 'logger'

module Aws
  module SessionStore
    module DynamoDB
      describe Table do
        context 'Mock Table Methods Tests', integration: true do
          let(:table_name) { "sessionstore-integration-test-#{Time.now.to_i}" }
          let(:options) { { table_name: table_name } }
          let(:io) { StringIO.new }

          before { allow(Table).to receive(:logger) { Logger.new(io) } }

          it 'Creates and deletes a new table' do
            Table.create_table(options)

            # second attempt should warn
            Table.create_table(options)

            expect(io.string).to include("Table #{table_name} created, waiting for activation...\n")
            expect(io.string).to include("Table #{table_name} is now ready to use.\n")
            expect(io.string).to include("Table #{table_name} already exists, skipping creation.\n")

            # now delete table
            Table.delete_table(options)
          end
        end
      end
    end
  end
end
