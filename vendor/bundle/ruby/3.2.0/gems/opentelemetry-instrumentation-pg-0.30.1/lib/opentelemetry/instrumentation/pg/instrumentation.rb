# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module PG
      # The Instrumentation class contains logic to detect and install the Pg instrumentation
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        MINIMUM_VERSION = Gem::Version.new('1.1.0')

        install do |_config|
          require_dependencies
          patch_client
        end

        present do
          defined?(::PG)
        end

        compatible do
          gem_version > Gem::Version.new(MINIMUM_VERSION)
        end

        option :peer_service, default: nil, validate: :string
        option :db_statement, default: :obfuscate, validate: %I[omit include obfuscate]
        option :obfuscation_limit, default: 2000, validate: :integer

        private

        def gem_version
          Gem::Version.new(::PG::VERSION)
        end

        def require_dependencies
          require_relative 'patches/connection'
        end

        def patch_client
          ::PG::Connection.prepend(Patches::Connection)
        end
      end
    end
  end
end
