# frozen_string_literal: true

module DatabaseConsistency
  module Databases
    # Factory for database adapters
    class Factory
      attr_reader :adapter

      # @param [String] adapter
      def initialize(adapter)
        @adapter = adapter
      end

      # @return [DatabaseConsistency::Databases::Types::Base]
      def type(type)
        sqlite? ? Types::Sqlite.new(type) : Types::Base.new(type)
      end

      private

      # @return [Boolean]
      def sqlite?
        adapter == 'SQLite'
      end
    end
  end
end
