require 'html_tokenizer_ext'

module HtmlTokenizer
  class ParserError < RuntimeError
    attr_reader :position, :line, :column
    def initialize(message, position, line, column)
      super(message)
      @position = position
      @line = line
      @column = column
    end
  end
end
