# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for enum checkers
    class EnumChecker < BaseChecker
      attr_reader :model, :enum

      def self.processor
        Processors::EnumsProcessor
      end

      def initialize(model, enum)
        super()
        @model = model
        @enum = enum
      end

      def column_or_attribute_name
        @column_or_attribute_name ||= enum.to_s
      end

      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
