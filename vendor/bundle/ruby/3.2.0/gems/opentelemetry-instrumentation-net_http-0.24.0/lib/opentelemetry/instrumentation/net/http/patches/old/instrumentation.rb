# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module Net
      module HTTP
        module Patches
          module Old
            # Module to prepend to Net::HTTP for instrumentation
            module Instrumentation
              HTTP_METHODS_TO_SPAN_NAMES = Hash.new { |h, k| h[k] = "HTTP #{k}" }
              USE_SSL_TO_SCHEME = { false => 'http', true => 'https' }.freeze

              # Constant for the HTTP status range
              HTTP_STATUS_SUCCESS_RANGE = (100..399)

              def request(req, body = nil, &)
                # Do not trace recursive call for starting the connection
                return super unless started?

                return super if untraced?

                attributes = {
                  OpenTelemetry::SemanticConventions::Trace::HTTP_METHOD => req.method,
                  OpenTelemetry::SemanticConventions::Trace::HTTP_SCHEME => USE_SSL_TO_SCHEME[use_ssl?],
                  OpenTelemetry::SemanticConventions::Trace::HTTP_TARGET => req.path,
                  OpenTelemetry::SemanticConventions::Trace::NET_PEER_NAME => @address,
                  OpenTelemetry::SemanticConventions::Trace::NET_PEER_PORT => @port
                }.merge!(OpenTelemetry::Common::HTTP::ClientContext.attributes)

                tracer.in_span(
                  HTTP_METHODS_TO_SPAN_NAMES[req.method],
                  attributes: attributes,
                  kind: :client
                ) do |span|
                  OpenTelemetry.propagation.inject(req)

                  super.tap do |response|
                    annotate_span_with_response!(span, response)
                  end
                end
              end

              private

              def connect
                return super if untraced?

                if proxy?
                  conn_address = proxy_address
                  conn_port    = proxy_port
                else
                  conn_address = address
                  conn_port    = port
                end

                attributes = {
                  OpenTelemetry::SemanticConventions::Trace::NET_PEER_NAME => conn_address,
                  OpenTelemetry::SemanticConventions::Trace::NET_PEER_PORT => conn_port
                }.merge!(OpenTelemetry::Common::HTTP::ClientContext.attributes)

                if use_ssl? && proxy?
                  span_name = 'HTTP CONNECT'
                  span_kind = :client
                else
                  span_name = 'connect'
                  span_kind = :internal
                end

                tracer.in_span(span_name, attributes: attributes, kind: span_kind) do
                  super
                end
              end

              def annotate_span_with_response!(span, response)
                return unless response&.code

                status_code = response.code.to_i

                span.set_attribute(OpenTelemetry::SemanticConventions::Trace::HTTP_STATUS_CODE, status_code)
                span.status = OpenTelemetry::Trace::Status.error unless HTTP_STATUS_SUCCESS_RANGE.cover?(status_code)
              end

              def tracer
                Net::HTTP::Instrumentation.instance.tracer
              end

              def untraced?
                untraced_context? || untraced_host?
              end

              def untraced_host?
                return true if Net::HTTP::Instrumentation.instance.config[:untraced_hosts]&.any? do |host|
                  host.is_a?(Regexp) ? host.match?(@address) : host == @address
                end

                false
              end

              def untraced_context?
                OpenTelemetry::Common::Utilities.untraced?
              end
            end
          end
        end
      end
    end
  end
end
