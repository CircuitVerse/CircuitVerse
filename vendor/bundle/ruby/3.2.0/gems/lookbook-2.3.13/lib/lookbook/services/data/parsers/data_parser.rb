module Lookbook
  class DataParser < Service
    def initialize(input, fail_silently: false, fallback: nil)
      @input = input
      @fail_silently = fail_silently
      @fallback = fallback
    end

    def call
      result = @input.present? ? parse(@input) : @fallback
      result.is_a?(Hash) ? result.deep_symbolize_keys : result
    rescue => exception
      @fail_silently ? @fallback : raise(exception)
    end

    protected

    def parse(input)
      raise ParserError.new "DataParser must be subclassed with a :parse method defined"
    end
  end
end
