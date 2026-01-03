# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks that foreign key has a cascade option matching dependent option
    class ForeignKeyCascadeChecker < AssociationChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :cascade_option,
        :primary_table,
        :foreign_table,
        :primary_key,
        :foreign_key
      )

      OPTION_TO_CASCADE = {
        delete: [:cascade],
        delete_all: [:cascade],
        nullify: [:nullify],
        restrict_with_exception: [nil, :restrict],
        restrict_with_error: [nil, :restrict]
      }.freeze

      DEPENDENT_OPTIONS = OPTION_TO_CASCADE.keys.freeze

      private

      def preconditions
        !association.polymorphic? &&
          !association.belongs_to? &&
          foreign_key &&
          DEPENDENT_OPTIONS.include?(dependent_option)
      rescue StandardError
        false
      end

      # Table of possible statuses
      # | foreign key | status |
      # | ----------- | ------ |
      # | persisted   | ok     |
      # | missing     | fail   |
      def check
        if correlated_cascade_constraint?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :missing_foreign_key_cascade)
        end
      end

      def required_foreign_key_cascade
        OPTION_TO_CASCADE[dependent_option]
      end

      def correlated_cascade_constraint?
        required_foreign_key_cascade.include?(foreign_key_on_delete_option)
      end

      def dependent_option
        association.options[:dependent]
      end

      def foreign_key_on_delete_option
        foreign_key.options[:on_delete]
      end

      def foreign_key
        @foreign_key ||=
          association.klass
                     .connection
                     .foreign_keys(association.klass.table_name)
                     .find { |fk| fk.column == association.foreign_key.to_s }
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_message: nil,
          error_slug: error_slug,
          primary_table: association.table_name.to_s,
          primary_key: association.association_primary_key.to_s,
          foreign_table: association.active_record.table_name.to_s,
          foreign_key: association.foreign_key.to_s,
          cascade_option: required_foreign_key_cascade,
          **report_attributes
        )
      end
    end
  end
end
