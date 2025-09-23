require "htmlbeautifier"

module Lookbook
  class CodeBeautifier < Service
    attr_reader :source, :opts

    def initialize(source, opts = {})
      @source = source.to_s
      @opts = opts
    end

    def call
      language = opts.fetch(:language, "html")
      stripped_source = source.strip
      result = (language.downcase == "html") ? HtmlBeautifier.beautify(stripped_source, opts) : stripped_source
      result.to_s.strip.html_safe
    rescue
      source.strip.html_safe
    end
  end
end
