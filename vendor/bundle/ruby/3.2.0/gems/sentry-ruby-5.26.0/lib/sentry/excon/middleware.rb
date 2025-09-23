# frozen_string_literal: true

module Sentry
  module Excon
    OP_NAME = "http.client"

    class Middleware < ::Excon::Middleware::Base
      def initialize(stack)
        super
        @instrumenter = Instrumenter.new
      end

      def request_call(datum)
        @instrumenter.start_transaction(datum)
        @stack.request_call(datum)
      end

      def response_call(datum)
        @instrumenter.finish_transaction(datum)
        @stack.response_call(datum)
      end
    end

    class Instrumenter
      SPAN_ORIGIN = "auto.http.excon"
      BREADCRUMB_CATEGORY = "http"

      include Utils::HttpTracing

      def start_transaction(env)
        return unless Sentry.initialized?

        current_span = Sentry.get_current_scope&.span
        @span = current_span&.start_child(op: OP_NAME, start_timestamp: Sentry.utc_now.to_f, origin: SPAN_ORIGIN)

        request_info = extract_request_info(env)

        if propagate_trace?(request_info[:url])
          set_propagation_headers(env[:headers])
        end
      end

      def finish_transaction(response)
        return unless @span

        response_status = response[:response][:status]
        request_info = extract_request_info(response)

        if record_sentry_breadcrumb?
          record_sentry_breadcrumb(request_info, response_status)
        end

        set_span_info(@span, request_info, response_status)
      ensure
        @span&.finish
      end

      private

      def extract_request_info(env)
        url = env[:scheme] + "://" + env[:hostname] + env[:path]
        result = { method: env[:method].to_s.upcase, url: url }

        if Sentry.configuration.send_default_pii
          result[:query] = env[:query]

          # Handle excon 1.0.0+
          result[:query] = build_nested_query(result[:query]) unless result[:query].is_a?(String)

          result[:body] = env[:body]
        end

        result
      end
    end
  end
end
