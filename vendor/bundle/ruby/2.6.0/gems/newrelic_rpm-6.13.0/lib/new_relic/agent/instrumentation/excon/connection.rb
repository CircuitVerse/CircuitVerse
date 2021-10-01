# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module ::Excon
  class Connection
    # @connection is deprecated in newer excon versions and replaced with @data
    def newrelic_connection_params
      (@data || @connection)
    end

    def newrelic_resolved_request_params(request_params)
      resolved = newrelic_connection_params.merge(request_params)
      resolved[:headers] = resolved[:headers].merge(request_params[:headers] || {})
      resolved
    end

    def request_with_newrelic_trace(params, &block)
      resolved_params = newrelic_resolved_request_params(params)
      wrapped_request = ::NewRelic::Agent::HTTPClients::ExconHTTPRequest.new(resolved_params)
      segment = NewRelic::Agent::Tracer.start_external_request_segment(
        library: wrapped_request.type,
        uri: wrapped_request.uri,
        procedure: wrapped_request.method
      )

      begin
        response = nil
        segment.add_request_headers wrapped_request

        response = NewRelic::Agent::Tracer.capture_segment_error segment do
          request_without_newrelic_trace(resolved_params, &block)
        end

        wrapped_response = ::NewRelic::Agent::HTTPClients::ExconHTTPResponse.new(response)
        segment.process_response_headers wrapped_response

        response
      ensure
        segment.finish if segment
      end
    end

    def self.install_newrelic_instrumentation
      alias request_without_newrelic_trace request
      alias request request_with_newrelic_trace
    end
  end
end
