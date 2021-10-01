# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :httprb

  depends_on do
    defined?(HTTP) && defined?(HTTP::Client)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing http.rb instrumentation'
    require 'new_relic/agent/distributed_tracing/cross_app_tracing'
    require 'new_relic/agent/http_clients/http_rb_wrappers'
  end

  executes do
    class HTTP::Client
      def perform_with_newrelic_trace(request, options)
        wrapped_request = ::NewRelic::Agent::HTTPClients::HTTPRequest.new(request)

        begin
          segment = NewRelic::Agent::Tracer.start_external_request_segment(
            library: wrapped_request.type,
            uri: wrapped_request.uri,
            procedure: wrapped_request.method
          )

          segment.add_request_headers wrapped_request

          response = NewRelic::Agent::Tracer.capture_segment_error segment do
            perform_without_newrelic_trace(request, options)
          end

          wrapped_response = ::NewRelic::Agent::HTTPClients::HTTPResponse.new response
          segment.process_response_headers wrapped_response

          response
        ensure
          segment.finish if segment
        end
      end

      alias perform_without_newrelic_trace perform
      alias perform perform_with_newrelic_trace
    end
  end
end
