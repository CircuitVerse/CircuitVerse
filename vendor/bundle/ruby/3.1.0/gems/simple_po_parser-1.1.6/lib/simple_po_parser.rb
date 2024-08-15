# encoding: utf-8

require 'simple_po_parser/error'
require 'simple_po_parser/parser'
require 'simple_po_parser/tokenizer'
require 'simple_po_parser/version'

module SimplePoParser
  class << self
    # parse po file
    #
    # returns an array of po messages as hashes
    def parse(path)
      Tokenizer.new.parse_file(path)
    end

    # parses a single message.
    def parse_message(message)
      Parser.new.parse(message)
    end
  end

end
