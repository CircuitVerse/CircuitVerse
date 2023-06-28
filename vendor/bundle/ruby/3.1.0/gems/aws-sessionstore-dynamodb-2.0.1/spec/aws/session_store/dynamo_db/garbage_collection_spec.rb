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

describe Aws::SessionStore::DynamoDB::GarbageCollection do
  def items(min, max)
    items = []
    (min..max).each do |i|
      items << { 'session_id' => { s: i.to_s } }
    end
    items
  end

  def format_scan_result
    items = []
    (31..49).each do |i|
      items << { 'session_id' => { s: i.to_s } }
    end

    items.each_with_object([]) do |item, rqst_array|
      rqst_array << { delete_request: { key: item } }
    end
  end

  def collect_garbage
    options = { dynamo_db_client: dynamo_db_client, max_age: 100, max_stale: 100 }
    Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage(options)
  end

  let(:scan_resp1) do
    resp = {
      items: items(0, 49),
      count: 50,
      scanned_count: 1000,
      last_evaluated_key: {}
    }
  end

  let(:scan_resp2) do
    {
      items: items(0, 31),
      last_evaluated_key: { 'session_id' => { s: '31' } }
    }
  end

  let(:scan_resp3) do
    {
      items: items(31, 49),
      last_evaluated_key: {}
    }
  end

  let(:write_resp1) do
    {
      unprocessed_items: {}
    }
  end

  let(:write_resp2) do
    {
      unprocessed_items: {
        'sessions' => [
          {
            delete_request: {
              key: {
                'session_id' =>
                {
                  s: '1'
                }
              }
            }
          },
          {
            delete_request: {
              key: {
                'session_id' =>
                {
                  s: '17'
                }
              }
            }
          }
        ]
      }
    }
  end

  let(:dynamo_db_client) {Aws::DynamoDB::Client.new(stub_responses: true)}

  context 'Mock DynamoDB client with garbage collection' do
    it 'processes scan result greater than 25 and deletes in batches of 25' do
      expect(dynamo_db_client).to receive(:scan)
        .exactly(1).times.and_return(scan_resp1)
      expect(dynamo_db_client).to receive(:batch_write_item).
        exactly(2).times.and_return(write_resp1)
      collect_garbage
    end

    it 'gets scan results then returns last evaluated key and resumes scanning' do
      expect(dynamo_db_client).to receive(:scan).
        exactly(1).times.and_return(scan_resp2)
      expect(dynamo_db_client).to receive(:scan).
        exactly(1).times.with(hash_including(exclusive_start_key: scan_resp2[:last_evaluated_key])).
        and_return(scan_resp3)
      expect(dynamo_db_client).to receive(:batch_write_item).
        exactly(3).times.and_return(write_resp1)
      collect_garbage
    end

    it 'it formats unprocessed_items and then batch deletes them' do
      expect(dynamo_db_client).to receive(:scan).
        exactly(1).times.and_return(scan_resp3)
      expect(dynamo_db_client).to receive(:batch_write_item).ordered.
        with(request_items: { 'sessions' => format_scan_result }).
        and_return(write_resp2)
      expect(dynamo_db_client).to receive(:batch_write_item).ordered.with(
        request_items: {
          'sessions' => [
            {
              delete_request: {
                key: {
                  'session_id' =>
                  {
                    s: '1'
                  }
                }
              }
            },
            {
              delete_request: {
                key: {
                  'session_id' =>
                  {
                    s: '17'
                  }
                }
              }
            }
          ]
        }
      ).and_return(write_resp1)
      collect_garbage
    end
  end
end
