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

module Aws
  module SessionStore
    module DynamoDB
      describe RackMiddleware do
        include Rack::Test::Methods

        before { @options = {} }

        def ensure_data_updated(mutated_data)
          expect(dynamo_db_client).to receive(:update_item) do |options|
            if mutated_data
              expect(options[:attribute_updates]['data']).not_to be_nil
            else
              expect(options[:attribute_updates]['data']).to be_nil
            end
          end
        end

        before do
          @options = {
            dynamo_db_client: dynamo_db_client,
            secret_key: 'watermelon_cherries'
          }
        end

        let(:base_app) { MultiplierApplication.new }
        let(:app) { RackMiddleware.new(base_app, @options) }

        let(:sample_packed_data) do
          [Marshal.dump('multiplier' => 1)].pack('m*')
        end

        let(:dynamo_db_client) do
          double(
            'Aws::DynamoDB::Client',
            delete_item: 'Deleted',
            list_tables: { table_names: ['Sessions'] },
            get_item: { item: { 'data' => sample_packed_data } },
            update_item: { attributes: { created_at: 'now' } }
          )
        end

        context 'Testing best case session storage with mock client' do
          it 'stores session data in session object' do
            get '/'
            expect(last_request.session.to_hash).to eq('multiplier' => 1)
          end

          it 'creates a new HTTP cookie when Cookie not supplied' do
            get '/'
            expect(last_response.body).to eq('All good!')
            expect(last_response['Set-Cookie']).to be_truthy
          end

          it 'loads/manipulates a session based on id from HTTP-Cookie' do
            get '/'
            expect(last_request.session.to_hash).to eq('multiplier' => 1)

            get '/'
            expect(last_request.session.to_hash).to eq('multiplier' => 2)
          end

          it 'does not rewrite Cookie if cookie previously/accuarately set' do
            get '/'
            expect(last_response['Set-Cookie']).not_to be_nil

            get '/'
            expect(last_response['Set-Cookie']).to be_nil
          end

          it 'does not set cookie when defer option is specifed' do
            @options[:defer] = true
            get '/'
            expect(last_response['Set-Cookie']).to be_nil
          end

          it 'creates new session with false/nonexistant http-cookie id' do
            get '/'
            expect(last_response['Set-Cookie']).not_to eq('1234')
            expect(last_response['Set-Cookie']).not_to be_nil
          end

          it 'expires after specified time and sets date for cookie to expire' do
            @options[:expire_after] = 0
            get '/'
            session_cookie = last_response['Set-Cookie']

            get '/'
            expect(last_response['Set-Cookie']).not_to be_nil
            expect(last_response['Set-Cookie']).not_to eq(session_cookie)
          end

          it "doesn't reset Cookie if not outside expire date" do
            @options[:expire_after] = 3600
            get '/'
            session_cookie = last_response['Set-Cookie']
            get '/'
            expect(last_response['Set-Cookie']).to eq(session_cookie)
          end

          it 'will not set a session cookie when defer is true' do
            @options[:defer] = true
            get '/'
            expect(last_response['Set-Cookie']).to be_nil
          end

          it 'generates sid and migrates data to new sid when renew is selected' do
            @options[:renew] = true
            get '/'
            expect(last_request.session.to_hash).to eq('multiplier' => 1)
            session_cookie = last_response['Set-Cookie']

            get '/', 'HTTP_Cookie' => session_cookie
            expect(last_response['Set-Cookie']).not_to eq(session_cookie)
            expect(last_request.session.to_hash).to eq('multiplier' => 2)
          end

          it "doesn't resend unmutated data" do
            ensure_data_updated(true)
            @options[:renew] = true
            get '/'

            ensure_data_updated(false)
            get '/', {}, { 'rack.session' => { 'multiplier' => nil } }
          end
        end
      end
    end
  end
end
