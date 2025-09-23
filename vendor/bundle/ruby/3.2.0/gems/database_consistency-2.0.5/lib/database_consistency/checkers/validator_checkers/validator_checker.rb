# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for validator checker
    class ValidatorChecker < BaseChecker
      attr_reader :model, :attribute, :validator

      def self.processor
        Processors::ValidatorsProcessor
      end

      def initialize(model, attribute, validator)
        super()
        @model = model
        @attribute = attribute
        @validator = validator
      end

      # @return [String]
      def column_or_attribute_name
        @column_or_attribute_name ||= attribute.to_s
      end

      # @return [String]
      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
