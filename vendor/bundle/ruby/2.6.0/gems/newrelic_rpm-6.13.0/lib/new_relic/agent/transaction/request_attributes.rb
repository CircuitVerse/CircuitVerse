# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/http_clients/uri_util'

module NewRelic
  module Agent
    class Transaction
      class RequestAttributes
        attr_reader :request_path, :referer, :accept, :content_length, :content_type,
                    :host, :port, :user_agent, :request_method

        HTTP_ACCEPT_HEADER_KEY = "HTTP_ACCEPT".freeze

        def initialize request
          @request_path = path_from_request request
          @referer = referer_from_request request
          @accept = attribute_from_env request, HTTP_ACCEPT_HEADER_KEY
          @content_length = content_length_from_request request
          @content_type = attribute_from_request request, :content_type
          @host = attribute_from_request request, :host
          @port = port_from_request request
          @user_agent = attribute_from_request request, :user_agent
          @request_method = attribute_from_request request, :request_method
        end

        def assign_agent_attributes txn
         default_destinations = AttributeFilter::DST_TRANSACTION_TRACER|
                                AttributeFilter::DST_TRANSACTION_EVENTS|
                                AttributeFilter::DST_ERROR_COLLECTOR

          if referer
            txn.add_agent_attribute :'request.headers.referer', referer, AttributeFilter::DST_ERROR_COLLECTOR
          end

          if request_path
            txn.add_agent_attribute :'request.uri',
                                    request_path,
                                    AttributeFilter::DST_TRANSACTION_TRACER |
                                    AttributeFilter::DST_ERROR_COLLECTOR
          end

          if accept
            txn.add_agent_attribute :'request.headers.accept', accept, default_destinations
          end

          if content_length
            txn.add_agent_attribute :'request.headers.contentLength', content_length, default_destinations
          end

          if content_type
            txn.add_agent_attribute :'request.headers.contentType', content_type, default_destinations
          end

          if host
            txn.add_agent_attribute :'request.headers.host', host, default_destinations
          end

          if user_agent
            txn.add_agent_attribute :'request.headers.userAgent', user_agent, default_destinations
          end

          if request_method
            txn.add_agent_attribute :'request.method', request_method, default_destinations
          end
        end

        private

        # Make a safe attempt to get the referer from a request object, generally successful when
        # it's a Rack request.

        def referer_from_request request
          if referer = attribute_from_request(request, :referer)
            HTTPClients::URIUtil.strip_query_string referer.to_s
          end
        end

        # In practice we expect req to be a Rack::Request or ActionController::AbstractRequest
        # (for older Rails versions).  But anything that responds to path can be passed to
        # perform_action_with_newrelic_trace.
        #
        # We don't expect the path to include a query string, however older test helpers for
        # rails construct the PATH_INFO enviroment variable improperly and we're generally
        # being defensive.

        ROOT_PATH = "/".freeze

        def path_from_request request
          path = attribute_from_request(request, :path) || ''
          path = HTTPClients::URIUtil.strip_query_string(path)
          path.empty? ? ROOT_PATH : path
        end

        def content_length_from_request request
          if content_length = attribute_from_request(request, :content_length)
            content_length.to_i
          end
        end

        def port_from_request request
          if port = attribute_from_request(request, :port)
            port.to_i
          end
        end

        def attribute_from_request request, attribute_method
          if request.respond_to? attribute_method
            request.send(attribute_method)
          end
        end

        def attribute_from_env request, key
          if env = attribute_from_request(request, :env)
            env[key]
          end
        end
      end
    end
  end
end
