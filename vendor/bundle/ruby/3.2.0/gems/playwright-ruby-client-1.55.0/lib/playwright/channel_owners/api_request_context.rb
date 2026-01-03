require 'base64'
require 'cgi'

module Playwright
  define_channel_owner :APIRequestContext do
    private def after_initialize
      @tracing = ChannelOwners::Tracing.from(@initializer['tracing'])
      @timeout_settings = TimeoutSettings.new
    end

    private def _update_timeout_settings(timeout_settings)
      @timeout_settings = timeout_settings
    end

    def dispose(reason: nil)
      @close_reason = reason
      @channel.send_message_to_server('dispose')
    end

    def delete(url, **options)
      fetch_options = options.merge(method: 'DELETE')
      fetch(url, **fetch_options)
    end

    def head(url, **options)
      fetch_options = options.merge(method: 'HEAD')
      fetch(url, **fetch_options)
    end

    def get(url, **options)
      fetch_options = options.merge(method: 'GET')
      fetch(url, **fetch_options)
    end

    def patch(url, **options)
      fetch_options = options.merge(method: 'PATCH')
      fetch(url, **fetch_options)
    end

    def put(url, **options)
      fetch_options = options.merge(method: 'PUT')
      fetch(url, **fetch_options)
    end

    def post(url, **options)
      fetch_options = options.merge(method: 'POST')
      fetch(url, **fetch_options)
    end

    def fetch(
          urlOrRequest,
          data: nil,
          failOnStatusCode: nil,
          form: nil,
          headers: nil,
          ignoreHTTPSErrors: nil,
          maxRedirects: nil,
          maxRetries: nil,
          method: nil,
          multipart: nil,
          params: nil,
          timeout: nil)

      if [ChannelOwners::Request, String].none? { |type| urlOrRequest.is_a?(type) }
        raise ArgumentError.new("First argument must be either URL string or Request")
      end
      if urlOrRequest.is_a?(ChannelOwners::Request)
        request = urlOrRequest
        url = nil
      else
        url = urlOrRequest
        request = nil
      end
      _inner_fetch(
        request,
        url,
        data: data,
        failOnStatusCode: failOnStatusCode,
        form: form,
        headers: headers,
        ignoreHTTPSErrors: ignoreHTTPSErrors,
        maxRedirects: maxRedirects,
        maxRetries: maxRetries,
        method: method,
        multipart: multipart,
        params: params,
        timeout: timeout,
      )
    end

    private def _inner_fetch(
          request,
          url,
          data: nil,
          failOnStatusCode: nil,
          form: nil,
          headers: nil,
          ignoreHTTPSErrors: nil,
          maxRedirects: nil,
          maxRetries: nil,
          method: nil,
          multipart: nil,
          params: nil,
          timeout: nil)
      if @close_reason
        raise TargetClosedError.new(message: @close_reason)
      end
      if [data, form, multipart].compact.count > 1
        raise ArgumentError.new("Only one of 'data', 'form' or 'multipart' can be specified")
      end
      if maxRedirects && maxRedirects < 0
        raise ArgumentError.new("'maxRedirects' should be greater than or equal to '0'")
      end
      if maxRetries && maxRetries < 0
        raise ArgumentError.new("'maxRetries' should be greater than or equal to '0'")
      end

      headers_obj = headers || request&.headers
      fetch_params = {
        url: url || request.url,
        params: map_params_to_array(params),
        method: method || request&.method || 'GET',
        headers: headers_obj ? HttpHeaders.new(headers_obj).as_serialized : nil,
      }

      json_data = nil
      form_data = nil
      multipart_data = nil
      post_data_buffer = nil
      if data
        case data
        when String
          if headers_obj&.any? { |key, value| key.downcase == 'content-type' && value == 'application/json' }
            json_data = json_parsable?(data) ? data : data.to_json
          else
            post_data_buffer = data
          end
        when Hash, Array, Numeric, true, false
          json_data = data.to_json
        else
          raise ArgumentError.new("Unsupported 'data' type: #{data.class}")
        end
      elsif form
        form_data = object_to_array(form)
      elsif multipart
        multipart_data = multipart.map do |name, value|
          if file_payload?(value)
            { name: name, file: file_payload_to_json(value) }
          else
            { name: name, value: value.to_s }
          end
        end
      end

      if !json_data && !form_data && !multipart_data
        post_data_buffer ||= request&.post_data_buffer
      end
      if post_data_buffer
        fetch_params[:postData] = Base64.strict_encode64(post_data_buffer)
      end
      fetch_params[:jsonData] = json_data
      fetch_params[:formData] = form_data
      fetch_params[:multipartData] = multipart_data
      fetch_params[:timeout] = @timeout_settings.timeout(timeout)
      fetch_params[:failOnStatusCode] = failOnStatusCode
      fetch_params[:ignoreHTTPSErrors] = ignoreHTTPSErrors
      fetch_params[:maxRedirects] = maxRedirects
      fetch_params[:maxRetries] = maxRetries
      fetch_params.compact!
      response = @channel.send_message_to_server('fetch', fetch_params)

      APIResponseImpl.new(self, response)
    end

    private def file_payload?(value)
      value.is_a?(Hash) &&
        %w(name mimeType buffer).all? { |key| value.has_key?(key) || value.has_key?(key.to_sym) }
    end

    private def file_payload_to_json(payload)
      {
        name: payload[:name] || payload['name'],
        mimeType: payload[:mimeType] || payload['mimeType'],
        buffer: Base64.strict_encode64(payload[:buffer] || payload['buffer'])
      }
    end

    private def map_params_to_array(params)
      if params.is_a?(String)
        unless params.start_with?('?')
          raise ArgumentError.new("Query string must start with '?'")
        end
        query_string_to_array(params[1..-1])
      else
        object_to_array(params)
      end
    end

    private def query_string_to_array(query_string)
      params = CGI.parse(query_string)

      params.map do |key, values|
        values.map do |value|
          { name: key, value: value }
        end
      end.flatten
    end

    private def object_to_array(hash)
      hash&.map do |key, value|
        { name: key, value: value.to_s }
      end
    end

    private def json_parsable?(data)
      return false unless data.is_a?(String)
      begin
        JSON.parse(data)
        true
      rescue JSON::ParserError
        false
      end
    end
  end
end
