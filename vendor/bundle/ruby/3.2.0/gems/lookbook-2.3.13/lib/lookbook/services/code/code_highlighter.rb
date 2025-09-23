require "rouge"
require "htmlentities"

module Lookbook
  class CodeHighlighter < Service
    attr_reader :source

    def initialize(source, opts = {})
      @source = source.to_s
      @opts = opts
    end

    def opts
      (@opts.is_a?(String) || @opts.is_a?(Symbol)) ? {language: @opts} : @opts.to_h
    end

    def call
      coder = HTMLEntities.new
      decoded_source = coder.decode(source)
      language = opts.fetch(:language, "ruby")
      formatter = LookbookFormatter.new(language: language, **opts)
      lexer = Rouge::Lexer.find(language.to_s) || Rouge::Lexer.find("plaintext")
      formatter.format(lexer.lex(decoded_source)).html_safe
    end

    class LookbookFormatter < Rouge::Formatters::HTML
      def initialize(**opts)
        @opts = opts
        @highlight_lines = opts[:highlight_lines].to_a || []
        @start_line = opts[:start_line] || 1
        @language = opts[:language]
      end

      def stream(tokens, &block)
        lines = token_lines(tokens)

        yield "<div class='wrapper'>"

        if @opts[:line_numbers]
          yield "<div class='line-numbers'>"
          lines.each.with_index do |line, i|
            yield "<div class='line #{"highlighted" if highlighted?(i)}'><span class='line-number'>#{line_number(i)}</span></div>"
          end
          yield "</div>"
        end

        yield "<pre class='code highlight' data-lang='#{@language}'><code>"
        lines.each.with_index do |line_tokens, i|
          yield "<div class='line#{" highlighted" if highlighted?(i)}'>"
          line_tokens.each do |token, value|
            yield span(token, value)
          end
          yield "</div>"
        end
        yield "</code></pre>"

        yield "</div>"
      end

      def highlighted?(i)
        @highlight_lines.include?(i + 1)
      end

      def line_number(i)
        @start_line + i
      end
    end
  end
end
