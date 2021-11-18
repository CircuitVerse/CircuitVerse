# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :curb

  CURB_MIN_VERSION = Gem::Version.new("0.8.1")

  depends_on do
    defined?(::Curl) && defined?(::Curl::CURB_VERSION) &&
      Gem::Version.new(::Curl::CURB_VERSION) >= CURB_MIN_VERSION
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Curb instrumentation'
    require 'new_relic/agent/distributed_tracing/cross_app_tracing'
    require 'new_relic/agent/http_clients/curb_wrappers'
  end

  executes do
    class Curl::Easy

      attr_accessor :_nr_instrumented,
                    :_nr_failure_instrumented,
                    :_nr_http_verb,
                    :_nr_header_str,
                    :_nr_original_on_header,
                    :_nr_original_on_complete,
                    :_nr_original_on_failure,
                    :_nr_serial

      # We have to hook these three methods separately, as they don't use
      # Curl::Easy#http
      if RUBY_VERSION < "2.7.0"
        def http_head_with_newrelic(*args, &blk)
          self._nr_http_verb = :HEAD
          http_head_without_newrelic(*args, &blk)
        end
      else
        def http_head_with_newrelic(*args, **kwargs, &blk)
          self._nr_http_verb = :HEAD
          http_head_without_newrelic(*args, **kwargs, &blk)
        end
      end

      alias_method :http_head_without_newrelic, :http_head
      alias_method :http_head, :http_head_with_newrelic

      if RUBY_VERSION < "2.7.0"
        def http_post_with_newrelic(*args, &blk)
          self._nr_http_verb = :POST
          http_post_without_newrelic(*args, &blk)
        end
      else
        def http_post_with_newrelic(*args, **kwargs, &blk)
          self._nr_http_verb = :POST
          http_post_without_newrelic(*args, **kwargs, &blk)
        end
      end

      alias_method :http_post_without_newrelic, :http_post
      alias_method :http_post, :http_post_with_newrelic

      if RUBY_VERSION < "2.7.0"
        def http_put_with_newrelic(*args, &blk)
          self._nr_http_verb = :PUT
          http_put_without_newrelic(*args, &blk)
        end
      else
        def http_put_with_newrelic(*args, **kwargs, &blk)
          self._nr_http_verb = :PUT
          http_put_without_newrelic(*args, **kwargs, &blk)
        end
      end

      alias_method :http_put_without_newrelic, :http_put
      alias_method :http_put, :http_put_with_newrelic


      # Hook the #http method to set the verb.
      def http_with_newrelic verb
        self._nr_http_verb = verb.to_s.upcase
        http_without_newrelic( verb )
      end

      alias_method :http_without_newrelic, :http
      alias_method :http, :http_with_newrelic

      # Hook the #perform method to mark the request as non-parallel.
      def perform_with_newrelic
        self._nr_http_verb ||= :GET
        self._nr_serial = true
        perform_without_newrelic
      end

      alias_method :perform_without_newrelic, :perform
      alias_method :perform, :perform_with_newrelic

      # Record the HTTP verb for future #perform calls
      def method_with_newrelic verb
        self._nr_http_verb = verb.upcase
        method_without_newrelic(verb)
      end

      alias_method :method_without_newrelic, :method
      alias_method :method, :method_with_newrelic

      # We override this method in order to ensure access to header_str even
      # though we use an on_header callback
      def header_str_with_newrelic
        if self._nr_serial
          self._nr_header_str
        else
          # Since we didn't install a header callback for a non-serial request,
          # just fall back to the original implementation.
          header_str_without_newrelic
        end
      end

      alias_method :header_str_without_newrelic, :header_str
      alias_method :header_str, :header_str_with_newrelic
    end # class Curl::Easy


    class Curl::Multi
      include NewRelic::Agent::MethodTracer

      # Add CAT with callbacks if the request is serial
      def add_with_newrelic(curl)
        if curl.respond_to?(:_nr_serial) && curl._nr_serial
          hook_pending_request(curl) if NewRelic::Agent::Tracer.tracing_enabled?
        end

        return add_without_newrelic curl
      end

      alias_method :add_without_newrelic, :add
      alias_method :add, :add_with_newrelic

      # Trace as an External/Multiple call if the first request isn't serial.
      def perform_with_newrelic(&blk)
        return perform_without_newrelic if first_request_is_serial?

        trace_execution_scoped("External/Multiple/Curb::Multi/perform") do
          perform_without_newrelic(&blk)
        end
      end

      alias_method :perform_without_newrelic, :perform
      alias_method :perform, :perform_with_newrelic


      # Instrument the specified +request+ (a Curl::Easy object)
      # and set up cross-application tracing if it's enabled.
      def hook_pending_request(request)
        wrapped_request, wrapped_response = wrap_request(request)

        segment = NewRelic::Agent::Tracer.start_external_request_segment(
          library: wrapped_request.type,
          uri: wrapped_request.uri,
          procedure: wrapped_request.method
        )

        segment.add_request_headers wrapped_request

        # install all callbacks
        unless request._nr_instrumented
          install_header_callback(request, wrapped_response)
          install_completion_callback(request, wrapped_response, segment)
          install_failure_callback(request, wrapped_response, segment)
          request._nr_instrumented = true
        end
      rescue => err
        NewRelic::Agent.logger.error("Untrapped exception", err)
      end


      # Create request and response adapter objects for the specified +request+
      # NOTE: Although strange to wrap request and response at once, it works
      # because curb's callback mechanism updates the instantiated wrappers
      # during the life-cycle of external request
      def wrap_request(request)
        return NewRelic::Agent::HTTPClients::CurbRequest.new(request),
               NewRelic::Agent::HTTPClients::CurbResponse.new(request)
      end

      # Install a callback that will record the response headers
      # to enable CAT linking
      def install_header_callback(request, wrapped_response)
        original_callback = request.on_header
        request._nr_original_on_header = original_callback
        request._nr_header_str = nil
        request.on_header do |header_data|
          if original_callback
            original_callback.call header_data
          else
            wrapped_response.append_header_data header_data
            header_data.length
          end
        end
      end

      # Install a callback that will finish the trace.
      def install_completion_callback(request, wrapped_response, segment)
        original_callback = request.on_complete
        request._nr_original_on_complete = original_callback
        request.on_complete do |finished_request|
          begin
            segment.process_response_headers wrapped_response
          ensure
            segment.finish if segment
            # Make sure the existing completion callback is run, and restore the
            # on_complete callback to how it was before.
            original_callback.call(finished_request) if original_callback
            remove_instrumentation_callbacks(request)
          end
        end
      end

      # Install a callback that will fire on failures
      # NOTE:  on_failure is not always called, so we're not always
      # unhooking the callback.  No harm/no foul in production, but
      # definitely something to beware of if debugging callback issues
      # _nr_failure_instrumented exists to prevent infinitely chaining
      # our on_failure callback hook.
      def install_failure_callback(request, wrapped_response, segment)
        return if request._nr_failure_instrumented
        original_callback = request.on_failure
        request._nr_original_on_failure = original_callback
        request.on_failure do |failed_request, error|
          begin
            if segment
              noticible_error = NewRelic::Agent::NoticibleError.new error[0].name, error[-1]
              segment.notice_error noticible_error
            end
          ensure
            original_callback.call(failed_request, error) if original_callback
            remove_failure_callback(failed_request)
          end
          request._nr_failure_instrumented = true 
        end
      end

      # on_failure callbacks cannot be removed in the on_complete
      # callback where this method is invoked because on_complete
      # fires before the on_failure!
      def remove_instrumentation_callbacks(request)
        request.on_complete(&request._nr_original_on_complete)
        request.on_header(&request._nr_original_on_header)
        request._nr_instrumented = false
      end

      # We execute customer's on_failure callback (if any) and 
      # uninstall our hook here since the on_complete callback 
      # fires before the on_failure callback.
      def remove_failure_callback(request)
        request.on_failure(&request._nr_original_on_failure)
        request._nr_failure_instrumented = false
      end

      private

      def first_request_is_serial?
        return false unless (first = self.requests.first)

        # Before curb 0.9.8, requests was an array of Curl::Easy
        # instances.  Starting with 0.9.8, it's a Hash where the
        # values are Curl::Easy instances.
        #
        # So, requests.first will either be an_obj or [a_key, an_obj].
        # We need to handle either case.
        #
        first = first[-1] if first.is_a?(Array)

        first.respond_to?(:_nr_serial) && first._nr_serial
      end

    end # class Curl::Multi

  end
end
