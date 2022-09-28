module Tins
  class LRUCache
    include Enumerable

    class << self
      private

      my_nil = Object.new.freeze

      define_method(:not_exist) do
        my_nil
      end
    end

    def initialize(capacity)
      @capacity = capacity
      @data     = {}
    end

    attr_reader :capacity

    def [](key)
      case value = @data.delete(key){ not_exist }
      when not_exist
        nil
      else
        @data[key] = value
      end
    end

    def []=(key, value)
      @data.delete(key)
      @data[key] = value
      if @data.size > @capacity
        @data.delete(@data.keys.first)
      end
      value
    end

    def each(&block)
      @data.reverse_each(&block)
    end

    def delete(key)
      @data.delete(key)
    end

    def clear
      @data.clear
    end

    def size
      @data.size
    end

    private

    def not_exist
      self.class.send(:not_exist)
    end
  end
end
