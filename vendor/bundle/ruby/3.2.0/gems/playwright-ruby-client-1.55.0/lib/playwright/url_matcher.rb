module Playwright
  class UrlMatcher
    # @param url [String|Regexp]
    # @param base_url [String|nil]
    def initialize(url, base_url:)
      @url = url
      @base_url = base_url
    end

    def as_pattern
      case @url
      when String
        { glob: @url }
      when Regexp
        regex = JavaScript::Regex.new(@url)
        { regexSource: regex.source, regexFlags: regex.flag }
      else
        nil
      end
    end

    def match?(target_url)
      case @url
      when String
        joined_url == target_url || File.fnmatch?(@url, target_url)
      when Regexp
        @url.match?(target_url)
      else
        false
      end
    end

    private def joined_url
      if @base_url && !@url.start_with?('*')
        URI.join(@base_url, @url).to_s
      else
        @url
      end
    end
  end
end
