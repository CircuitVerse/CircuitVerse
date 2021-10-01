require 'oauth/request_proxy/base'
require 'rest-client'
require 'uri'
require 'cgi'

module OAuth::RequestProxy::RestClient
  class Request < OAuth::RequestProxy::Base
    proxies RestClient::Request
    
      def method
        request.method.to_s.upcase
      end

      def uri
        request.url
      end

      def parameters
        if options[:clobber_request]
          options[:parameters] || {}
        else
          post_parameters.merge(query_params).merge(options[:parameters] || {})
        end
      end

    protected

      def query_params
        query = URI.parse(request.url).query
        query ? CGI.parse(query) : {}
      end

      def request_params
      end
      
      def post_parameters
        # Post params are only used if posting form data
        if method == 'POST' || method == 'PUT'
          OAuth::Helper.stringify_keys(query_string_to_hash(request.payload.to_s) || {})
        else
          {}
        end
      end
      
   private
      
      def query_string_to_hash(query)
        keyvals = query.split('&').inject({}) do |result, q| 
          k,v = q.split('=')
          if !v.nil?
             result.merge({k => v})
          elsif !result.key?(k)
            result.merge({k => true})
          else
            result
          end
        end
        keyvals
      end
      
  end
end