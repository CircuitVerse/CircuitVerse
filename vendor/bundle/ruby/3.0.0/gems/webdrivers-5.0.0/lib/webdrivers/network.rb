# frozen_string_literal: true

require 'net/http'

module Webdrivers
  #
  # @api private
  #
  class Network
    class << self
      def get(url, limit = 10)
        Webdrivers.logger.debug "Making network call to #{url}"

        response = get_response(url, limit)
        case response
        when Net::HTTPSuccess
          response.body
        else
          raise NetworkError, "#{response.class::EXCEPTION_TYPE}: #{response.code} \"#{response.message}\" with #{url}"
        end
      end

      def get_url(url, limit = 10)
        Webdrivers.logger.debug "Making network call to #{url}"

        get_response(url, limit).uri.to_s
      end

      def get_response(url, limit = 10)
        raise ConnectionError, 'Too many HTTP redirects' if limit.zero?

        begin
          response = http.get_response(URI(url))
        rescue SocketError
          raise ConnectionError, "Can not reach #{url}"
        end

        Webdrivers.logger.debug "Get response: #{response.inspect}"

        if response.is_a?(Net::HTTPRedirection)
          location = response['location']
          Webdrivers.logger.debug "Redirected to #{location}"
          get_response(location, limit - 1)
        else
          response
        end
      end

      def http
        if using_proxy
          Net::HTTP.Proxy(Webdrivers.proxy_addr, Webdrivers.proxy_port,
                          Webdrivers.proxy_user, Webdrivers.proxy_pass)
        else
          Net::HTTP
        end
      end

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end
    end
  end
end
