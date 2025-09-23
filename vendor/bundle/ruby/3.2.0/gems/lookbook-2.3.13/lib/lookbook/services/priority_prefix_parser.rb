module Lookbook
  class PriorityPrefixParser < Service
    PRIORITY_PREFIX_REGEX = /^(\d+?)[-_]/

    attr_reader :input

    def initialize(input)
      @input = String(input)
    end

    def call
      matches = input.match(PRIORITY_PREFIX_REGEX)
      matches ? [matches[1].to_i, input.gsub(PRIORITY_PREFIX_REGEX, "")] : [nil, input]
    end
  end
end
