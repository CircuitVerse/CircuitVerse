# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for validator fraction checkers
    class ValidatorsFractionChecker < BaseChecker
      attr_reader :model, :attribute, :validators

      def self.processor
        Processors::ValidatorsFractionsProcessor
      end

      def initialize(model, attribute, validators)
        super()
        @model = model
        @attribute = attribute
        @validators = validators.select(&method(:filter))
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
