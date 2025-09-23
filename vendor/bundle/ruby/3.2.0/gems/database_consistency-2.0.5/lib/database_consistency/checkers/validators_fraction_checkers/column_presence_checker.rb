# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks if presence validator has non-null constraint in the database
    class ColumnPresenceChecker < ValidatorsFractionChecker
      WEAK_OPTIONS = %i[allow_nil allow_blank if unless on].freeze

      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :table_name,
        :column_name
      )

      private

      def filter(validator)
        validator.kind == :presence
      end

      def preconditions
        (regular_column || association) && model.connection.table_exists?(model.table_name) && validators.any?
      end

      def report_template(status, column_name:, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          table_name: model.table_name.to_s,
          column_name: column_name,
          **report_attributes
        )
      end

      def weak_option?
        validators.all? do |validator|
          result = validator.options.slice(*WEAK_OPTIONS).any?

          result = false if required_with_if?(validator)

          result
        end
      end

      def belongs_to_required_validates_foreign_key_disabled?
        ActiveRecord.version >= Gem::Version.new('7.1.0') &&
          !ActiveRecord.belongs_to_required_validates_foreign_key
      end

      def required_with_if?(validator)
        belongs_to_required_validates_foreign_key_disabled? &&
          validator.options[:message] == :required && validator.options[:if].present?
      end

      def check
        if regular_column
          analyse(attribute.to_s, type: :null_constraint_missing)
        else
          analyse_association
        end
      end

      def analyse_association
        reports = [analyse(association.foreign_key.to_s, type: :association_missing_null_constraint)]
        if association.polymorphic?
          reports << analyse(association.foreign_type.to_s, type: :association_foreign_type_missing_null_constraint)
        end
        reports.compact.presence
      end

      def analyse(column_name, type:)
        field = column(column_name)
        # If the column is missing there is nothing we can do.
        return if field.nil?

        can_be_null = field.null
        has_weak_option = weak_option?

        return report_template(:ok, column_name: column_name) if can_be_null == has_weak_option
        return report_template(:fail, error_slug: :possible_null, column_name: column_name) unless can_be_null

        report_template(:fail, error_slug: type, column_name: column_name)
      end

      def regular_column
        @regular_column ||= column(attribute.to_s)
      end

      def association
        @association ||=
          model
          .reflect_on_all_associations
          .find { |reflection| reflection.belongs_to? && reflection.name.to_s == attribute.to_s }
      end

      def column(name)
        model.columns.find { |field| field.name == name.to_s }
      end
    end
  end
end
