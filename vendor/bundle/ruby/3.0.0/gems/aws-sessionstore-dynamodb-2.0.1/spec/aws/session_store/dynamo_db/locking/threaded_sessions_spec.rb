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

describe Aws::SessionStore::DynamoDB::RackMiddleware do
  include Rack::Test::Methods

  def thread(mul_val, time, check)
    Thread.new do
      sleep(time)
      get '/'
      expect(last_request.session[:multiplier]).to eq(mul_val) if check
    end
  end

  def thread_exception(error)
    Thread.new { expect { get '/' }.to raise_error(error) }
  end

  def update_item_mock(options, update_method)
    if options[:return_values] == 'UPDATED_NEW' && options.key?(:expected)
      sleep(0.50)
      update_method.call(options)
    else
      update_method.call(options)
    end
  end

  let(:base_app) { MultiplierApplication.new }
  let(:app) { Aws::SessionStore::DynamoDB::RackMiddleware.new(base_app, @options) }

  context 'Mock Multiple Threaded Sessions', integration: true do
    before do
      @options = Aws::SessionStore::DynamoDB::Configuration.new.to_hash
      @options[:enable_locking] = true
      @options[:secret_key] = 'watermelon_smiles'

      update_method = @options[:dynamo_db_client].method(:update_item)
      expect(@options[:dynamo_db_client]).to receive(:update_item).at_least(:once) do |options|
        update_item_mock(options, update_method)
      end
    end

    it 'should wait for lock' do
      @options[:lock_expiry_time] = 2000

      get '/'
      expect(last_request.session[:multiplier]).to eq(1)

      t1 = thread(2, 0, false)
      t2 = thread(4, 0.25, true)
      t1.join
      t2.join
    end

    it 'should bust lock' do
      @options[:lock_expiry_time] = 100

      get '/'
      expect(last_request.session[:multiplier]).to eq(1)

      t1 = thread_exception(Aws::DynamoDB::Errors::ConditionalCheckFailedException)
      t2 = thread(2, 0.25, true)
      t1.join
      t2.join
    end

    it 'should throw exceeded time spent aquiring lock error' do
      @options[:lock_expiry_time] = 1000
      @options[:lock_retry_delay] = 100
      @options[:lock_max_wait_time] = 0.25

      get '/'
      expect(last_request.session[:multiplier]).to eq(1)

      t1 = thread(2, 0, false)
      sleep(0.25)
      t2 = thread_exception(Aws::SessionStore::DynamoDB::LockWaitTimeoutError)
      t1.join
      t2.join
    end
  end
end
