# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks if uniqueness validator has unique index in the database
    class MissingUniqueIndexChecker < ValidatorChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :table_name,
        :columns
      )

      def column_or_attribute_name
        @column_or_attribute_name ||= Helper.uniqueness_validator_columns(attribute, validator, model).join('+')
      end

      private

      # We skip check when:
      #  - validator is not a uniqueness validator
      def preconditions
        validator.kind == :uniqueness
      end

      # Table of possible statuses
      # | unique index | status |
      # | ------------ | ------ |
      # | persisted    | ok     |
      # | missing      | fail   |
      def check
        if unique_index
          report_template(:ok)
        else
          report_template(:fail, error_slug: :missing_unique_index)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          table_name: model.table_name,
          columns: sorted_uniqueness_validator_columns,
          **report_attributes
        )
      end

      def unique_index
        @unique_index ||= model.connection.indexes(model.table_name).find do |index|
          index.unique && Helper.extract_index_columns(index.columns).sort == sorted_uniqueness_validator_columns
        end
      end

      def sorted_uniqueness_validator_columns
        @sorted_uniqueness_validator_columns ||= Helper.sorted_uniqueness_validator_columns(attribute, validator, model)
      end
    end
  end
end
