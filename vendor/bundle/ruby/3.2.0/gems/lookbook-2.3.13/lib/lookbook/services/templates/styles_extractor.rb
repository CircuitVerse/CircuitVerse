require "css_parser"

module Lookbook
  class StylesExtractor < Service
    STYLE_TAGS_REGEX = /<style(?:\s[^>]*)?>((?:(?!<\/style>).)*)<\/style>/m

    attr_reader :content

    def initialize(content)
      @content = content.to_s
    end

    def call
      styles = extract_styles(content)
      rest = strip_styles(content)
      [styles, rest]
    end

    protected

    def extract_styles(text)
      css_parser = ::CssParser::Parser.new
      text.scan(STYLE_TAGS_REGEX).flatten.map(&:strip).each do |css|
        css_parser.load_string!(css.strip)
      end

      styles = []
      css_parser.each_selector do |selector, declarations, specificity|
        styles << "#{selector} { #{declarations} }"
      end
      styles
    end

    def strip_styles(text)
      text.gsub(STYLE_TAGS_REGEX, "").strip
    end
  end
end
