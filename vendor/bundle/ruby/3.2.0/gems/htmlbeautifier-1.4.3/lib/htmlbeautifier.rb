# frozen_string_literal: true

require "htmlbeautifier/builder"
require "htmlbeautifier/html_parser"
require "htmlbeautifier/version"

module HtmlBeautifier
  #
  # Returns a beautified HTML/HTML+ERB document as a String.
  # html must be an object that responds to +#to_s+.
  #
  # Available options are:
  # tab_stops - an integer for the number of spaces to indent, default 2.
  # Deprecated: see indent.
  # indent - what to indent with ("  ", "\t" etc.), default "  "
  # stop_on_errors - raise an exception on a badly-formed document. Default
  # is false, i.e. continue to process the rest of the document.
  # initial_level - The entire output will be indented by this number of steps.
  # Default is 0.
  # keep_blank_lines - an integer for the number of consecutive empty lines
  # to keep in output.
  #
  def self.beautify(html, options = {})
    if options[:tab_stops]
      options[:indent] = " " * options[:tab_stops]
    end
    String.new.tap { |output|
      HtmlParser.new.scan html.to_s, Builder.new(output, options)
    }
  end
end
