# frozen_string_literal: true

module DatabaseConsistency
  # The container that stores information for debugging purposes
  class DebugContext
    include Singleton

    self.class.delegate :with, to: :instance
    self.class.delegate :output, to: :instance

    def initialize
      clear!
    end

    def with(context)
      context.each do |key, value|
        store[key] = value
      end

      result = yield

      context.each_key do |key|
        store.delete(key)
      end

      result
    end

    def output(destination)
      store.each do |key, value|
        destination.puts("#{key}: #{value}")
      end
    end

    private

    attr_reader :store

    def clear!
      @store = {}
    end
  end
end
