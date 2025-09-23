# frozen_string_literal: true

require "strscan"

module HtmlBeautifier
  class Parser
    def initialize
      @maps = []
      yield self if block_given?
    end

    def map(pattern, method)
      @maps << [pattern, method]
    end

    def scan(subject, receiver)
      @scanner = StringScanner.new(subject)
      dispatch(receiver) until @scanner.eos?
    end

    def source_so_far
      @scanner.string[0...@scanner.pos]
    end

    def source_line_number
      [source_so_far.chomp.split(%r{\n}).count, 1].max
    end

    private

    def dispatch(receiver)
      _, method = @maps.find { |pattern, _| @scanner.scan(pattern) }
      raise "Unmatched sequence" unless method

      receiver.__send__(method, *extract_params(@scanner))
    rescue => e
      raise "#{e.message} on line #{source_line_number}"
    end

    def extract_params(scanner)
      return [scanner[0]] unless scanner[1]

      params = []
      i = 1
      while scanner[i]
        params << scanner[i]
        i += 1
      end
      params
    end
  end
end
