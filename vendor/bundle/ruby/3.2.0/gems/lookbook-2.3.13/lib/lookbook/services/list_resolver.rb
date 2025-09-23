module Lookbook
  class ListResolver < Service
    attr_reader :item_set

    def initialize(to_include = nil, item_set = nil)
      @to_include = to_include
      @item_set = Array(item_set).compact.uniq.map(&:to_s)
    end

    def call(&resolver)
      included = to_include.inject([]) do |result, name|
        if name == "*"
          result += item_set.select { |item| !result.include?(item) }
        elsif item_set.include?(name)
          result << name
        end
        result
      end

      resolved = resolver ? included.map { |item| resolver.call(item) } : included
      resolved.compact
    end

    def to_include
      case @to_include
      when true
        ["*"]
      when false
        []
      else
        Array(@to_include).compact.uniq.map(&:to_s)
      end
    end
  end
end
