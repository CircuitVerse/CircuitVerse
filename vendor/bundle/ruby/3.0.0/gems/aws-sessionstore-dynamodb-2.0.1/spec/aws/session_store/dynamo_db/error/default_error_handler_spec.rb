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

describe Aws::SessionStore::DynamoDB do
  include Rack::Test::Methods

  instance_exec(&ConstantHelpers)

  before do
    @options = { dynamo_db_client: client, secret_key: 'meltingbutter' }
  end

  let(:base_app) { MultiplierApplication.new }
  let(:app) { Aws::SessionStore::DynamoDB::RackMiddleware.new(base_app, @options) }
  let(:client) { double('Aws::DynamoDB::Client') }

  context 'Error handling for Rack Middleware with default error handler' do
    it 'raises error for missing secret key' do
      allow(client).to receive(:update_item).and_raise(missing_key_error)
      expect { get '/' }.to raise_error(missing_key_error)
    end

    it 'catches exception for inaccurate table name and raises error ' do
      allow(client).to receive(:update_item).and_raise(resource_error)
      expect { get '/' }.to raise_error(resource_error)
    end

    it 'catches exception for inaccurate table key' do
      allow(client).to receive(:update_item).and_raise(key_error)
      allow(client).to receive(:get_item).and_raise(key_error)

      get '/'
      expect(last_request.env['rack.errors'].string).to include(key_error_msg)
    end
  end

  context 'Test ExceptionHandler with true as return value for handle_error' do
    it 'raises all errors' do
      @options[:raise_errors] = true
      allow(client).to receive(:update_item).and_raise(client_error)
      expect { get '/' }.to raise_error(client_error)
    end

    it 'catches exception for inaccurate table key and raises error' do
      @options[:raise_errors] = true
      allow(client).to receive(:update_item).and_raise(key_error)
      expect { get '/' }.to raise_error(key_error)
    end
  end
end
