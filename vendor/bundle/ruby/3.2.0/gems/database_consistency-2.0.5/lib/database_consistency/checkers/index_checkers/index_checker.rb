# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for index checkers
    class IndexChecker < BaseChecker
      attr_reader :model, :index

      def self.processor
        Processors::IndexesProcessor
      end

      def initialize(model, index)
        super()
        @model = model
        @index = index
      end

      def column_or_attribute_name
        @column_or_attribute_name ||= index.name.to_s
      end

      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
