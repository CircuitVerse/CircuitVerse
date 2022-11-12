# encoding: utf-8

module SimplePoParser
  # Split a PO file into single PO message entities (a message is seperated by two newline)
  class Tokenizer
    def initialize
      @messages = []
    end

    def parse_file(path)
      file = File.open(path, "r")
      if(file.gets =~ /\r$/)
        # detected windows line ending
        file.close
        file = File.open(path, "rt")
      else
        file.rewind
      end
      file.each_line("\n\n") do |block|
        block.strip! # dont parse empty blocks
        @messages << parse_block(block) if block != ''
      end
      @messages
    end

  private
    def parse_block(block)
      Parser.new.parse(block)
    end
  end
end
