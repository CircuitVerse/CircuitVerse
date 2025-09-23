require "cgi"

module Lookbook
  class SearchParamEncoder < Service
    attr_reader :data

    def initialize(data)
      @data = data.to_h
    end

    def call
      json = JSON.generate(data)
      CGI.escape(json)
    end
  end
end
