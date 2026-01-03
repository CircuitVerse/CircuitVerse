# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for model checkers
    class ModelChecker < BaseChecker
      attr_reader :model

      def self.processor
        Processors::ModelsProcessor
      end

      def initialize(model)
        super()
        @model = model
      end

      def column_or_attribute_name
        'self'
      end

      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
