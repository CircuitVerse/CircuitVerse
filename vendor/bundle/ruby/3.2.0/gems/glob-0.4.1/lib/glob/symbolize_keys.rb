# frozen_string_literal: true

module Glob
  module SymbolizeKeys
    def self.call(target)
      case target
      when Hash
        target.each_with_object({}) do |(key, value), buffer|
          buffer[key.to_s.to_sym] = SymbolizeKeys.call(value)
        end
      when Array
        target.map {|item| SymbolizeKeys.call(item) }
      else
        target
      end
    end
  end
end
