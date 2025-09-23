require 'base64'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_network.py
  define_channel_owner :Request do
    private def after_initialize
      @redirected_from = ChannelOwners::Request.from_nullable(@initializer['redirectedFrom'])
      @redirected_from&.send(:update_redirected_to, self)
      @provisional_headers = RawHeaders.new(@initializer['headers'])
      @timing = {
        startTime: 0,
        domainLookupStart: -1,
        domainLookupEnd: -1,
        connectStart: -1,
        secureConnectionStart: -1,
        connectEnd: -1,
        requestStart: -1,
        responseStart: -1,
        responseEnd: -1,
      }
      @fallback_overrides = {}
      @url = @initializer['url']
    end

    private def fallback_overrides
      @fallback_overrides
    end

    def apply_fallback_overrides(overrides)
      allowed_key = %i[url method headers postData]
      overrides.each do |key, value|
        raise ArgumentError.new("invalid key: #{key}") unless allowed_key.include?(key)
        @fallback_overrides[key] = value
      end
      @fallback_overrides
    end

    def url
      @fallback_overrides[:url] || @url
    end

    private def internal_url
      @url
    end

    def resource_type
      @initializer['resourceType']
    end

    def method
      @fallback_overrides[:method] || @initializer['method']
    end

    def post_data
      post_data_buffer
    end

    def post_data_json
      data = post_data
      return unless data

      content_type = headers['content-type']
      return unless content_type

      if content_type.include?("application/x-www-form-urlencoded")
        URI.decode_www_form(data).to_h
      else
        JSON.parse(data)
      end
    end

    def post_data_buffer
      if (override = @fallback_overrides[:postData])
        return override
      end

      if (base64_content = @initializer['postData'])
        Base64.strict_decode64(base64_content)
      else
        nil
      end
    end

    def response
      resp = @channel.send_message_to_server('response')
      ChannelOwners::Response.from_nullable(resp)
    end

    class FramePageNotReadyError < StandardError
      MESSAGE = [
        'Frame for this navigation request is not available, because the request',
        'was issued before the frame is created. You can check whether the request',
        'is a navigation request by calling isNavigationRequest() method.',
      ].join('\n').freeze

      def initialize
        super(MESSAGE)
      end
    end

    def frame
      ChannelOwners::Frame.from(@initializer['frame']).tap do |result|
        unless result.page
          raise FramePageNotReadyError.new
        end
      end
    end

    def navigation_request?
      @initializer['isNavigationRequest']
    end

    def failure
      @failure_text
    end

    attr_reader :redirected_from, :redirected_to, :timing

    def headers
      if (override = @fallback_overrides[:headers])
        RawHeaders.new(HttpHeaders.new(override).as_serialized).headers
      else
        @provisional_headers.headers
      end
    end

    # @return [RawHeaders|nil]
    private def actual_headers
      if (override = @fallback_overrides[:headers])
        RawHeaders.new(HttpHeaders.new(override).as_serialized)
      else
        @actual_headers ||= raw_request_headers
      end
    end

    private def raw_request_headers
      RawHeaders.new(@channel.send_message_to_server('rawRequestHeaders'))
    end

    def all_headers
      actual_headers.headers
    end

    def headers_array
      actual_headers.headers_array
    end

    def header_value(name)
      actual_headers.get(name)
    end

    def header_values(name)
      actual_headers.get_all(name)
    end

    def sizes
      res = response
      unless res
        raise 'Unable to fetch sizes for failed request'
      end

      res.send(:sizes)
    end

    private def update_redirected_to(request)
      @redirected_to = request
    end

    private def update_failure_text(failure_text)
      @failure_text = failure_text
    end

    private def update_timings(
                  start_time:,
                  domain_lookup_start:,
                  domain_lookup_end:,
                  connect_start:,
                  secure_connection_start:,
                  connect_end:,
                  request_start:,
                  response_start:)

      @timing[:startTime] = start_time
      @timing[:domainLookupStart] = domain_lookup_start
      @timing[:domainLookupEnd] = domain_lookup_end
      @timing[:connectStart] = connect_start
      @timing[:secureConnectionStart] = secure_connection_start
      @timing[:connectEnd] = connect_end
      @timing[:requestStart] = request_start
      @timing[:responseStart] = response_start
    end

    private def update_response_end_timing(response_end_timing)
      @timing[:responseEnd] = response_end_timing
    end
  end
end
