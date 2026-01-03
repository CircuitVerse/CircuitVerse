# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks missing NOT NULL constraint for boolean columns
    class ThreeStateBooleanChecker < ColumnChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :table_name,
        :column_name
      )

      private

      # column should be a boolean and table shouldn't be a view
      def preconditions
        column.type == :boolean && model.connection.table_exists?(model.table_name)
      end

      def check
        if valid?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :three_state_boolean)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          table_name: model.table_name,
          column_name: column.name,
          **report_attributes
        )
      end

      # @return [Boolean]
      def valid?
        !column.null
      end
    end
  end
end
