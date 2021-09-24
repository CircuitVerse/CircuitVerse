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

describe Aws::SessionStore::DynamoDB::Configuration do
  let(:defaults) do
    {
      table_name: 'sessions',
      table_key: 'session_id',
      consistent_read: true,
      read_capacity: 10,
      write_capacity: 5,
      raise_errors: false
    }
  end

  let(:expected_file_opts) do
    {
      consistent_read: true,
      table_name: 'NewTable',
      table_key: 'Somekey',
    }
  end

  let(:client) { Aws::DynamoDB::Client.new(stub_responses: true) }

  let(:runtime_options) do
    {
      table_name: 'SessionTable',
      table_key: 'session_id_stuff'
    }
  end

  def expected_options(opts)
    cfg = Aws::SessionStore::DynamoDB::Configuration.new(opts)
    expected_opts = defaults.merge(expected_file_opts).merge(opts)
    expect(cfg.to_hash).to include(expected_opts)
  end

  before do
    allow(Aws::DynamoDB::Client).to receive(:new).and_return(client)
  end

  context 'Configuration Tests' do
    it 'configures option with out runtime,YAML or ENV options' do
      cfg = Aws::SessionStore::DynamoDB::Configuration.new
      expect(cfg.to_hash).to include(defaults)
    end

    it 'configures accurate option hash with runtime options, no YAML or ENV' do
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(runtime_options)
      expected_opts = defaults.merge(runtime_options)
      expect(cfg.to_hash).to include(expected_opts)
    end

    it 'merge YAML and runtime options giving runtime precendence' do
      config_path = File.dirname(__FILE__) + '/app_config.yml'
      runtime_opts = { config_file: config_path }.merge(runtime_options)
      expected_options(runtime_opts)
    end

    it 'throws an exception when wrong path for file' do
      config_path = 'Wrong path!'
      runtime_opts = { config_file: config_path }.merge(runtime_options)
      expect { cfg = Aws::SessionStore::DynamoDB::Configuration.new(runtime_opts) }.to raise_error(Errno::ENOENT)
    end
  end
end
