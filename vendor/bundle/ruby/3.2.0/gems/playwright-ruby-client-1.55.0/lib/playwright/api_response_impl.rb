module Playwright
  define_api_implementation :APIResponseImpl do
    include Utils::Errors::TargetClosedErrorMethods

    # @params context [APIRequestContext]
    # @params initializer [Hash]
  	def initialize(context, initializer)
      @request = context
      @initializer = initializer
      @headers = RawHeaders.new(initializer['headers'])
    end

    def to_s
      "#<APIResponse url=#{url} status=#{status} status_text=#{status_text}>"
    end

    def url
      @initializer['url']
    end

    def ok
      (200...300).include?(status)
    end
    alias_method :ok?, :ok

    def status
      @initializer['status']
    end

    def status_text
      @initializer['statusText']
    end

    def headers
      @headers.headers
    end

    def headers_array
      @headers.headers_array
    end

    class AlreadyDisposedError < StandardError
      def initialize
        super('Response has been disposed')
      end
    end

    def body
      binary = @request.channel.send_message_to_server("fetchResponseBody", fetchUid: fetch_uid)
      raise AlreadyDisposedError.new unless binary
      Base64.strict_decode64(binary)
    rescue => err
      if target_closed_error?(err)
        raise AlreadyDisposedError.new
      else
        raise
      end
    end
    alias_method :text, :body

    def json
      JSON.parse(text)
    end

    def dispose
      @request.channel.send_message_to_server("disposeAPIResponse", fetchUid: fetch_uid)
    end

    private def _request
      @request
    end

    private def fetch_uid
      @initializer['fetchUid']
    end
  end
end
