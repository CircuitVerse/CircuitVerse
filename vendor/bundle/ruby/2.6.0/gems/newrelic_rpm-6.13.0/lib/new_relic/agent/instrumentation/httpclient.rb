# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :httpclient

  HTTPCLIENT_MIN_VERSION = '2.2.0'

  depends_on do
    defined?(HTTPClient) && defined?(HTTPClient::VERSION)
  end

  depends_on do
    minimum_supported_version = Gem::Version.new(HTTPCLIENT_MIN_VERSION)
    current_version = Gem::Version.new(HTTPClient::VERSION)

    current_version >= minimum_supported_version
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing HTTPClient instrumentation'
    require 'new_relic/agent/distributed_tracing/cross_app_tracing'
    require 'new_relic/agent/http_clients/httpclient_wrappers'
  end

  executes do
    class HTTPClient
      def do_get_block_with_newrelic(req, proxy, conn, &block)
        wrapped_request = NewRelic::Agent::HTTPClients::HTTPClientRequest.new(req)
        segment = NewRelic::Agent::Tracer.start_external_request_segment(
          library: wrapped_request.type,
          uri: wrapped_request.uri,
          procedure: wrapped_request.method
        )

        begin
          response = nil
          segment.add_request_headers wrapped_request

          NewRelic::Agent::Tracer.capture_segment_error segment do
            do_get_block_without_newrelic(req, proxy, conn, &block)
          end
          response = conn.pop
          conn.push response

          wrapped_response = ::NewRelic::Agent::HTTPClients::HTTPClientResponse.new(response)
          segment.process_response_headers wrapped_response

          response
        ensure
          segment.finish if segment
        end
      end

      alias do_get_block_without_newrelic do_get_block
      alias do_get_block do_get_block_with_newrelic
    end
  end
end
