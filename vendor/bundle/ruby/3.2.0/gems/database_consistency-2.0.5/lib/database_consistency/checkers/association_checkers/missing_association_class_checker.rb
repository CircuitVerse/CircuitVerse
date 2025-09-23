# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks if an association has existing class defined
    class MissingAssociationClassChecker < AssociationChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :class_name
      )

      private

      def preconditions
        !association.polymorphic?
      end

      def check
        association.klass
        report_template(:ok)
      rescue NameError
        report_template(:fail, error_slug: :missing_association_class)
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_message: nil,
          error_slug: error_slug,
          class_name: class_name,
          **report_attributes
        )
      end

      def class_name
        association.class_name
      rescue NoMethodError
        nil
      end
    end
  end
end
