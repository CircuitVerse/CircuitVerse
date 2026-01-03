# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks that primary column type is "uuid" and the model class defines `self.implicit_order_column`
    class ImplicitOrderingChecker < ColumnChecker
      Report = ReportBuilder.define(DatabaseConsistency::Report)

      private

      TARGET_COLUMN_TYPE = 'uuid'

      # We skip check when:
      # - adapter is not PostgreSQL
      # - column is not a primary key
      # - column type is not "uuid"
      def preconditions
        ActiveRecord::VERSION::MAJOR >= 6 &&
          Helper.postgresql? &&
          primary_field? &&
          column.sql_type.to_s.match(TARGET_COLUMN_TYPE)
      end

      # Table of possible statuses
      # | defined `self.implicit_order_column` | status |
      # | ----------------------------------- | ------ |
      # | yes                                 | ok     |
      # | no                                  | fail   |
      def check
        if implicit_order_column_defined?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :implicit_order_column_missing)
        end
      end

      # @return [Boolean]
      def primary_field?
        column.name.to_s == model.primary_key.to_s
      end

      # @return [Boolean]
      def implicit_order_column_defined?
        model.implicit_order_column.present?
      end
    end
  end
end
