# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks that a model has a corresponding table
    class MissingTableChecker < ModelChecker
      private

      def preconditions
        !model.abstract_class?
      end

      def check
        if model.table_exists?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :missing_table)
        end
      end
    end
  end
end
