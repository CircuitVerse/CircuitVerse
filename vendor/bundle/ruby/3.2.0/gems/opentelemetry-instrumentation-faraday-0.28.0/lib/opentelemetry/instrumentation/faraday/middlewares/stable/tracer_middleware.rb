# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module Faraday
      module Middlewares
        module Stable
          # TracerMiddleware propagates context and instruments Faraday requests
          # by way of its middleware system
          class TracerMiddleware < ::Faraday::Middleware
            HTTP_METHODS_SYMBOL_TO_STRING = {
              connect: 'CONNECT',
              delete: 'DELETE',
              get: 'GET',
              head: 'HEAD',
              options: 'OPTIONS',
              patch: 'PATCH',
              post: 'POST',
              put: 'PUT',
              trace: 'TRACE'
            }.freeze

            # Constant for the HTTP status range
            HTTP_STATUS_SUCCESS_RANGE = (100..399)

            def call(env)
              http_method = HTTP_METHODS_SYMBOL_TO_STRING[env.method]
              config = Faraday::Instrumentation.instance.config

              attributes = span_creation_attributes(
                http_method: http_method, url: env.url, config: config
              )

              OpenTelemetry::Common::HTTP::ClientContext.with_attributes(attributes) do |attrs, _|
                tracer.in_span(
                  http_method, attributes: attrs, kind: config.fetch(:span_kind)
                ) do |span|
                  OpenTelemetry.propagation.inject(env.request_headers)

                  if config[:enable_internal_instrumentation] == false
                    OpenTelemetry::Common::Utilities.untraced do
                      app.call(env).on_complete { |resp| trace_response(span, resp.status) }
                    end
                  else
                    app.call(env).on_complete { |resp| trace_response(span, resp.status) }
                  end
                rescue ::Faraday::Error => e
                  trace_response(span, e.response[:status]) if e.response

                  raise
                end
              end
            end

            private

            def span_creation_attributes(http_method:, url:, config:)
              attrs = {
                'http.request.method' => http_method,
                'url.full' => OpenTelemetry::Common::Utilities.cleanse_url(url.to_s),
                'faraday.adapter.name' => app.class.name
              }
              attrs['server.address'] = url.host if url.host
              attrs['peer.service'] = config[:peer_service] if config[:peer_service]

              attrs.merge!(
                OpenTelemetry::Common::HTTP::ClientContext.attributes
              )
            end

            # Versions prior to 1.0 do not define an accessor for app
            attr_reader :app if Gem::Version.new(Faraday::VERSION) < Gem::Version.new('1.0.0')

            def tracer
              Faraday::Instrumentation.instance.tracer
            end

            def trace_response(span, status)
              span.set_attribute('http.response.status_code', status)
              span.status = OpenTelemetry::Trace::Status.error unless HTTP_STATUS_SUCCESS_RANGE.cover?(status.to_i)
            end
          end
        end
      end
    end
  end
end
