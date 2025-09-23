# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks redundant database unique indexes
    class RedundantUniqueIndexChecker < IndexChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :index_name,
        :covered_index_name,
        :table_name
      )

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
      # | redundant  | fail   |
      #
      def check
        if covered_by_index
          report_template(:fail, error_slug: :redundant_unique_index)
        else
          report_template(:ok)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          index_name: index.name,
          covered_index_name: covered_by_index&.name,
          table_name: model.table_name,
          **report_attributes
        )
      end

      def covered_by_index
        @covered_by_index ||=
          model.connection.indexes(model.table_name).find do |another_index|
            next if index.name == another_index.name

            another_index.unique && clause_equals?(another_index) && contain_index?(another_index)
          end
      end

      def clause_equals?(another_index)
        another_index.where == index.where
      end

      def contain_index?(another_index)
        another_index_columns = Helper.extract_index_columns(another_index.columns)
        index_columns & another_index_columns == another_index_columns
      end

      def index_columns
        @index_columns ||= Helper.extract_index_columns(index.columns)
      end
    end
  end
end
