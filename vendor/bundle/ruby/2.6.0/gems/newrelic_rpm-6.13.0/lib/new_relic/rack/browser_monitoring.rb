# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'rack'
require 'new_relic/rack/agent_middleware'
require 'new_relic/agent/instrumentation/middleware_proxy'

module NewRelic::Rack
  # This middleware is used by the agent for the Real user monitoring (RUM)
  # feature, and will usually be automatically injected in the middleware chain.
  # If automatic injection is not working, you may manually use it in your
  # middleware chain instead.
  #
  # @api public
  #
  class BrowserMonitoring < AgentMiddleware
    # The maximum number of bytes of the response body that we will
    # examine in order to look for a RUM insertion point.
    SCAN_LIMIT = 50_000

    CONTENT_TYPE        = 'Content-Type'.freeze
    CONTENT_DISPOSITION = 'Content-Disposition'.freeze
    CONTENT_LENGTH      = 'Content-Length'.freeze
    ATTACHMENT          = 'attachment'.freeze
    TEXT_HTML           = 'text/html'.freeze

    BODY_START          = "<body".freeze
    HEAD_START          = "<head".freeze
    GT                  = ">".freeze

    def traced_call(env)
      result = @app.call(env)
      (status, headers, response) = result

      js_to_inject = NewRelic::Agent.browser_timing_header
      if (js_to_inject != "") && should_instrument?(env, status, headers)
        response_string = autoinstrument_source(response, headers, js_to_inject)
        if headers.key?(CONTENT_LENGTH)
          content_length = response_string ? response_string.bytesize : 0
          headers[CONTENT_LENGTH] = content_length.to_s
        end

        env[ALREADY_INSTRUMENTED_KEY] = true
        if response_string
          response = Rack::Response.new(response_string, status, headers)
          response.finish
        else
          result
        end
      else
        result
      end
    end

    ALREADY_INSTRUMENTED_KEY = "newrelic.browser_monitoring_already_instrumented"

    def should_instrument?(env, status, headers)
      NewRelic::Agent.config[:'browser_monitoring.auto_instrument'] &&
        status == 200 &&
        !env[ALREADY_INSTRUMENTED_KEY] &&
        is_html?(headers) &&
        !is_attachment?(headers) &&
        !is_streaming?(env, headers)
    end

    def is_html?(headers)
      headers[CONTENT_TYPE] && headers[CONTENT_TYPE].include?(TEXT_HTML)
    end

    def is_attachment?(headers)
      headers[CONTENT_DISPOSITION] && headers[CONTENT_DISPOSITION].include?(ATTACHMENT)
    end

    def is_streaming?(env, headers)
      return true if headers && headers['Transfer-Encoding'] == 'chunked'

      defined?(ActionController::Live) &&
        env['action_controller.instance'].class.included_modules.include?(ActionController::Live)
    end

    CHARSET_RE         = /<\s*meta[^>]+charset\s*=[^>]*>/im.freeze
    X_UA_COMPATIBLE_RE = /<\s*meta[^>]+http-equiv\s*=\s*['"]x-ua-compatible['"][^>]*>/im.freeze

    def autoinstrument_source(response, headers, js_to_inject)
      source = gather_source(response)
      close_old_response(response)
      return nil unless source

      # Only scan the first 50k (roughly) then give up.
      beginning_of_source = source[0..SCAN_LIMIT]

      if body_start = find_body_start(beginning_of_source)
        meta_tag_positions = [
          find_x_ua_compatible_position(beginning_of_source),
          find_charset_position(beginning_of_source)
        ].compact

        if !meta_tag_positions.empty?
          insertion_index = meta_tag_positions.max
        else
          insertion_index = find_end_of_head_open(beginning_of_source) || body_start
        end

        if insertion_index
          source = source[0...insertion_index] <<
            js_to_inject <<
            source[insertion_index..-1]
        else
          NewRelic::Agent.logger.debug "Skipping RUM instrumentation. Could not properly determine location to inject script."
        end
      else
        msg = "Skipping RUM instrumentation. Unable to find <body> tag in first #{SCAN_LIMIT} bytes of document."
        NewRelic::Agent.logger.log_once(:warn, :rum_insertion_failure, msg)
        NewRelic::Agent.logger.debug(msg)
      end

      source
    rescue => e
      NewRelic::Agent.logger.debug "Skipping RUM instrumentation on exception.", e
      nil
    end

    def gather_source(response)
      source = nil
      response.each {|fragment| source ? (source << fragment.to_s) : (source = fragment.to_s)}
      source
    end

    # Per "The Response > The Body" section of Rack spec, we should close
    # if our response is able. http://rack.rubyforge.org/doc/SPEC.html
    def close_old_response(response)
      if response.respond_to?(:close)
        response.close
      end
    end

    def find_body_start(beginning_of_source)
      beginning_of_source.index(BODY_START)
    end

    def find_x_ua_compatible_position(beginning_of_source)
      match = X_UA_COMPATIBLE_RE.match(beginning_of_source)
      match.end(0) if match
    end

    def find_charset_position(beginning_of_source)
      match = CHARSET_RE.match(beginning_of_source)
      match.end(0) if match
    end

    def find_end_of_head_open(beginning_of_source)
      head_open = beginning_of_source.index(HEAD_START)
      beginning_of_source.index(GT, head_open) + 1 if head_open
    end
  end
end
