# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks missing uniqueness validator
    class UniqueIndexChecker < IndexChecker
      private

      # We skip check when:
      #  - index is not unique
      def preconditions
        index.unique
      end

      # Table of possible statuses
      # | validation | status |
      # | ---------- | ------ |
      # | provided   | ok     |
      # | missing    | fail   |
      #
      def check
        if valid?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :missing_uniqueness_validation)
        end
      end

      def valid?
        uniqueness_validators = model.validators.select { |validator| validator.kind == :uniqueness }

        uniqueness_validators.any? do |validator|
          validator.attributes.any? do |attribute|
            sorted_index_columns == Helper.sorted_uniqueness_validator_columns(attribute, validator, model)
          end
        end
      end

      def sorted_index_columns
        @sorted_index_columns ||= Helper.extract_index_columns(index.columns).sort
      end
    end
  end
end
