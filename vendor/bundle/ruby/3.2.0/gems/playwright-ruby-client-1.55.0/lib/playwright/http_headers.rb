module Playwright
  class HttpHeaders
    # @param headers [Hash]
    def initialize(headers)
      @headers = headers
    end

    def as_serialized
      @headers.map do |key, value|
        { 'name' => key, 'value' => value }
      end
    end
  end
end
