# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Selenium
  module WebDriver
    module DriverExtensions
      module HasNetworkConditions

        #
        # Returns network conditions.
        #
        # @return [Hash]
        #

        def network_conditions
          @bridge.network_conditions
        end

        #
        # Sets network conditions
        #
        # @param [Hash] conditions
        # @option conditions [Integer] :latency
        # @option conditions [Integer] :throughput
        # @option conditions [Integer] :upload_throughput
        # @option conditions [Integer] :download_throughput
        # @option conditions [Boolean] :offline
        #

        def network_conditions=(conditions)
          conditions[:latency] ||= 0
          unless conditions.key?(:throughput)
            conditions[:download_throughput] ||= -1
            conditions[:upload_throughput] ||= -1
          end
          conditions[:offline] = false unless conditions.key?(:offline)

          @bridge.network_conditions = conditions
        end

        #
        # Resets Chromium network emulation settings.
        #

        def delete_network_conditions
          @bridge.delete_network_conditions
        end

      end # HasNetworkConditions
    end # DriverExtensions
  end # WebDriver
end # Selenium
