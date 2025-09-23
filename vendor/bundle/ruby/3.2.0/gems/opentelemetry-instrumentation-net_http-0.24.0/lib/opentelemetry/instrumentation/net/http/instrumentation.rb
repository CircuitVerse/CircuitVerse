# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module Net
      module HTTP
        # The Instrumentation class contains logic to detect and install the Net::HTTP
        # instrumentation
        class Instrumentation < OpenTelemetry::Instrumentation::Base
          install do |_config|
            patch_type = determine_semconv
            send(:"require_dependencies_#{patch_type}")
            send(:"patch_#{patch_type}")
          end

          present do
            defined?(::Net::HTTP)
          end

          ## Supported configuration keys for the install config hash:
          #
          # untraced_hosts: if a request's address matches any of the `String`
          #   or `Regexp` in this array, the instrumentation will not record a
          #   `kind = :client` representing the request and will not propagate
          #   context in the request.
          option :untraced_hosts, default: [], validate: :array

          private

          def determine_semconv
            stability_opt_in = ENV.fetch('OTEL_SEMCONV_STABILITY_OPT_IN', '')
            values = stability_opt_in.split(',').map(&:strip)

            if values.include?('http/dup')
              'dup'
            elsif values.include?('http')
              'stable'
            else
              'old'
            end
          end

          def require_dependencies_dup
            require_relative 'patches/dup/instrumentation'
          end

          def require_dependencies_old
            require_relative 'patches/old/instrumentation'
          end

          def require_dependencies_stable
            require_relative 'patches/stable/instrumentation'
          end

          def patch_dup
            ::Net::HTTP.prepend(Patches::Dup::Instrumentation)
          end

          def patch_old
            ::Net::HTTP.prepend(Patches::Old::Instrumentation)
          end

          def patch_stable
            ::Net::HTTP.prepend(Patches::Stable::Instrumentation)
          end
        end
      end
    end
  end
end
