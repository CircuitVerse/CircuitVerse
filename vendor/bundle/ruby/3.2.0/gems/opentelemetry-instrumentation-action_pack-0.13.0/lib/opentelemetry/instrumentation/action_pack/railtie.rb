# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module ActionPack
      # This Railtie installs Rack middleware to support Action Pack instrumentation
      class Railtie < ::Rails::Railtie
        config.before_initialize do |app|
          OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.install({})

          stability_opt_in = ENV.fetch('OTEL_SEMCONV_STABILITY_OPT_IN', '')
          values = stability_opt_in.split(',').map(&:strip)

          rack_middleware_args = if values.include?('http/dup')
                                   OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args_dup
                                 elsif values.include?('http')
                                   OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args_stable
                                 else
                                   OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args
                                 end

          app.middleware.insert_before(
            0,
            *rack_middleware_args
          )
        end
      end
    end
  end
end
