# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module HTTP
      module Patches
        # Module using old HTTP semantic conventions
        module Old
          # Module to prepend to HTTP::Client for instrumentation
          module Client
            # Constant for the HTTP status range
            HTTP_STATUS_SUCCESS_RANGE = (100..399)

            def perform(req, options)
              uri = req.uri
              request_method = req.verb.to_s.upcase
              span_name = create_request_span_name(request_method, uri.path)

              attributes = {
                'http.method' => request_method,
                'http.scheme' => uri.scheme,
                'http.target' => uri.path,
                'http.url' => "#{uri.scheme}://#{uri.host}",
                'net.peer.name' => uri.host,
                'net.peer.port' => uri.port
              }.merge!(OpenTelemetry::Common::HTTP::ClientContext.attributes)

              tracer.in_span(span_name, attributes: attributes, kind: :client) do |span|
                OpenTelemetry.propagation.inject(req.headers)
                super.tap do |response|
                  annotate_span_with_response!(span, response)
                end
              end
            end

            private

            def config
              OpenTelemetry::Instrumentation::HTTP::Instrumentation.instance.config
            end

            def annotate_span_with_response!(span, response)
              return unless response&.status

              status_code = response.status.to_i
              span.set_attribute('http.status_code', status_code)
              span.status = OpenTelemetry::Trace::Status.error unless HTTP_STATUS_SUCCESS_RANGE.cover?(status_code)
            end

            def create_request_span_name(request_method, request_path)
              if (implementation = config[:span_name_formatter])
                updated_span_name = implementation.call(request_method, request_path)
                updated_span_name.is_a?(String) ? updated_span_name : "HTTP #{request_method}"
              else
                "HTTP #{request_method}"
              end
            rescue StandardError
              "HTTP #{request_method}"
            end

            def tracer
              HTTP::Instrumentation.instance.tracer
            end
          end
        end
      end
    end
  end
end
