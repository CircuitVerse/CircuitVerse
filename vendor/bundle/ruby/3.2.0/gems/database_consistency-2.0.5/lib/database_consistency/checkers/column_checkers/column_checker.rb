# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for column checkers
    class ColumnChecker < BaseChecker
      attr_reader :model, :column

      def self.processor
        Processors::ColumnsProcessor
      end

      def initialize(model, column)
        super()
        @model = model
        @column = column
      end

      def column_or_attribute_name
        @column_or_attribute_name ||= column.name.to_s
      end

      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
