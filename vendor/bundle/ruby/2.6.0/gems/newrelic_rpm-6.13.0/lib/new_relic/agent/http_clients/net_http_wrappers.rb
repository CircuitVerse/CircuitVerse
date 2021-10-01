# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

require_relative 'abstract'

module NewRelic
  module Agent
    module HTTPClients
      class NetHTTPResponse < AbstractResponse

        def [](key)
          @wrapped_response[key]
        end

        def to_hash
          @wrapped_response.to_hash
        end
      end

      class NetHTTPRequest < AbstractRequest
        def initialize(connection, request)
          @connection = connection
          @request = request
        end

        NET_HTTP = 'Net::HTTP'

        def type
          NET_HTTP
        end

        HOST = 'host'
        COLON = ':'

        def host_from_header
          if hostname = self[HOST]
            hostname.split(COLON).first
          end
        end

        def host
          host_from_header || @connection.address
        end

        def method
          @request.method
        end

        def [](key)
          @request[key]
        end

        def []=(key, value)
          @request[key] = value
        end

        def uri
          case @request.path
          when /^https?:\/\//
            ::NewRelic::Agent::HTTPClients::URIUtil.parse_and_normalize_url(@request.path)
          else
            scheme = @connection.use_ssl? ? 'https' : 'http'
            ::NewRelic::Agent::HTTPClients::URIUtil.parse_and_normalize_url(
              "#{scheme}://#{@connection.address}:#{@connection.port}#{@request.path}"
              )
          end
        end
      end
    end
  end
end
