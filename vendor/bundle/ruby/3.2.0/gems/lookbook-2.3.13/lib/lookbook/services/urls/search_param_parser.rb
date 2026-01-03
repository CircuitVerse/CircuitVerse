require "cgi"

module Lookbook
  class SearchParamParser < Service
    attr_reader :str

    def initialize(str)
      @str = str.to_s.strip
    end

    def call
      json = CGI.unescape(str)
      JsonParser.call(json)
    end
  end
end
