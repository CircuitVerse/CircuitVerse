# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # The base class for association checkers
    class AssociationChecker < BaseChecker
      attr_reader :model, :association

      def self.processor
        Processors::AssociationsProcessor
      end

      def initialize(model, association)
        super()
        @model = model
        @association = association
      end

      def column_or_attribute_name
        @column_or_attribute_name ||= association.name.to_s
      end

      def table_or_model_name
        @table_or_model_name ||= model.name.to_s
      end
    end
  end
end
