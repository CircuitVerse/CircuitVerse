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

begin
  if ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start { add_filter 'spec' }
  end
rescue LoadError
end

$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'lib')

require 'rspec'
require 'aws-sessionstore-dynamodb'
require 'rack/test'

# Default Rack application
class MultiplierApplication
  def call(env)
    if env['rack.session'][:multiplier]
      env['rack.session'][:multiplier] *= 2
    else
      env['rack.session'][:multiplier] = 1
    end
    [200, { 'Content-Type' => 'text/plain' }, ['All good!']]
  end
end

ConstantHelpers = lambda do
  let(:token_error_msg) { 'The security token included in the request is invalid' }
  let(:resource_error) do
    Aws::DynamoDB::Errors::ResourceNotFoundException.new(double('Seahorse::Client::RequestContext'), resource_error_msg)
  end
  let(:resource_error_msg) { 'The Resource is not found.' }
  let(:key_error) { Aws::DynamoDB::Errors::ValidationException.new(double('Seahorse::Client::RequestContext'), key_error_msg) }
  let(:key_error_msg) { 'The provided key element does not match the schema' }
  let(:client_error) do
    Aws::DynamoDB::Errors::UnrecognizedClientException.new(double('Seahorse::Client::RequestContext'), client_error_msg)
  end
  let(:client_error_msg) { 'Unrecognized Client.'}
  let(:invalid_cookie) { { 'HTTP_COOKIE' => 'rack.session=ApplePieBlueberries' } }
  let(:invalid_session_data) { { 'rack.session' => { 'multiplier' => 1 } } }
  let(:rack_default_error_msg) { "Warning! Aws::SessionStore::DynamoDB failed to save session. Content dropped.\n" }
  let(:missing_key_error) { Aws::SessionStore::DynamoDB::MissingSecretKeyError }
end

RSpec.configure do |c|
  c.raise_errors_for_deprecations!
  c.before(:each, integration: true) do
    opts = { table_name: 'sessionstore-integration-test' }

    defaults = Aws::SessionStore::DynamoDB::Configuration::DEFAULTS
    defaults = defaults.merge(opts)
    stub_const('Aws::SessionStore::DynamoDB::Configuration::DEFAULTS', defaults)
    Aws::SessionStore::DynamoDB::Table.create_table(opts)
  end
end
