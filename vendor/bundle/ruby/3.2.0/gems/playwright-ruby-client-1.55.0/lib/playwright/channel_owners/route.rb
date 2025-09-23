require 'base64'
require 'mime/types'

module Playwright
  define_channel_owner :Route do
    private def set_handling_future(future)
      @handling_future = future
    end

    private def handling_with_result(done, &block)
      chain = @handling_future
      raise 'Route is already handled!' unless chain
      block.call
      @handling_future = nil
      chain.fulfill(done)
    end

    def request
      ChannelOwners::Request.from(@initializer['request'])
    end

    def abort(errorCode: nil)
      handling_with_result(true) do
        params = { requestUrl: request.send(:internal_url), errorCode: errorCode }.compact
        # TODO _race_with_page_close
        @channel.async_send_message_to_server('abort', params)
      end
    end

    def fulfill(
          body: nil,
          contentType: nil,
          headers: nil,
          json: nil,
          path: nil,
          status: nil,
          response: nil)
      handling_with_result(true) do
        option_status = status
        option_headers = headers
        option_body = body

        if json
          raise ArgumentError.new('Can specify either body or json parameters') if body
          option_body = JSON.generate(json)
        end

        params = {}

        if response
          option_status ||= response.status
          option_headers ||= response.headers

          if !body && !path && response.is_a?(APIResponseImpl)
            if response.send(:_request).send(:same_connection?, self)
              params[:fetchResponseUid] = response.send(:fetch_uid)
            else
              option_body = response.body
            end
          end
        end

        content =
          if option_body
            option_body
          elsif path
            File.read(path)
          else
            nil
          end

        param_headers = option_headers || {}
        if contentType
          param_headers['content-type'] = contentType
        elsif json
          param_headers['content-type'] = 'application/json'
        elsif path
          param_headers['content-type'] = mime_type_for(path)
        end

        if content
          if content.is_a?(String)
            params[:body] = content
            params[:isBase64] = false
          else
            params[:body] = Base64.strict_encode64(content)
            params[:isBase64] = true
          end
          param_headers['content-length'] ||= content.length.to_s
        end

        params[:status] = option_status || 200
        params[:headers] = HttpHeaders.new(param_headers).as_serialized
        params[:requestUrl] = request.send(:internal_url)

        @channel.async_send_message_to_server('fulfill', params)
      end
    end

    def fallback(headers: nil, method: nil, postData: nil, url: nil)
      overrides = {
        headers: headers,
        method: method,
        postData: postData,
        url: url,
      }.compact

      handling_with_result(false) do
        request.apply_fallback_overrides(overrides)
      end
    end

    def fetch(headers: nil, method: nil, postData: nil, url: nil, maxRedirects: nil, maxRetries: nil, timeout: nil)
      api_request_context = @context.request
      api_request_context.send(:_inner_fetch,
        request,
        url,
        headers: headers,
        method: method,
        data: postData,
        maxRedirects: maxRedirects,
        maxRetries: maxRetries,
        timeout: timeout,
      )
    end

    def continue(headers: nil, method: nil, postData: nil, url: nil)
      overrides = {
        headers: headers,
        method: method,
        postData: postData,
        url: url,
      }.compact

      handling_with_result(true) do
        request.apply_fallback_overrides(overrides)
        async_continue_route
      end
    end

    private def async_continue_route(internal: false)
      post_data_for_wire =
        if (post_data_from_overrides = request.send(:fallback_overrides)[:postData])
          post_data_for_wire = Base64.strict_encode64(post_data_from_overrides)
        else
          nil
        end

      params = request.send(:fallback_overrides).dup

      if params[:headers]
        params[:headers] = HttpHeaders.new(params[:headers]).as_serialized
      end

      if post_data_for_wire
        params[:postData] = post_data_for_wire
      end
      params[:requestUrl] = request.send(:internal_url)
      params[:isFallback] = internal

      # TODO _race_with_page_close
      @channel.async_send_message_to_server('continue', params)
    end

    def redirect_navigation_request(url)
      handling_with_result(true) do
        # TODO _race_with_page_close
        @channel.send_message_to_server('redirectNavigationRequest', { url: url })
      end
    end

    private def mime_type_for(filepath)
      mime_types = MIME::Types.type_for(filepath)
      mime_types.first.to_s || 'application/octet-stream'
    end

    private def update_context(context)
      @context = context
    end
  end
end
