# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks missing presence validator
    class NullConstraintChecker < ColumnChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :association_name
      )

      private

      # We skip check when:
      #  - column hasn't null constraint
      #  - column has default value
      #  - column has default function
      #  - column is a primary key
      #  - column is a timestamp
      def preconditions
        !column.null && column.default.nil? && !primary_field? && !timestamp_field? && !column.default_function
      end

      # Table of possible statuses
      # | validation | status |
      # | ---------- | ------ |
      # | provided   | ok     |
      # | missing    | fail   |
      #
      # We consider PresenceValidation, InclusionValidation, ExclusionValidation, NumericalityValidator with nil,
      # or required BelongsTo association using this column
      def check
        if valid?
          report_template(:ok)
        elsif belongs_to_association
          report_template(:fail, error_slug: :null_constraint_association_misses_validator)
        else
          report_template(:fail, error_slug: :null_constraint_misses_validator)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          association_name: belongs_to_association&.name&.to_s,
          **report_attributes
        )
      end

      def valid?
        validator?(:presence, column.name) ||
          validator?(:inclusion, column.name) ||
          numericality_validator_without_allow_nil? ||
          nil_exclusion_validator? ||
          (belongs_to_association && validator?(:presence, belongs_to_association.name))
      end

      def primary_field?
        column.name.to_s == model.primary_key.to_s
      end

      def timestamp_field?
        model.record_timestamps? && %w[created_at updated_at].include?(column.name)
      end

      def nil_exclusion_validator?
        model.validators.any? do |validator|
          validator.kind == :exclusion &&
            Helper.check_inclusion?(validator.attributes, column.name) &&
            validator.options[:in].include?(nil)
        end
      end

      def numericality_validator_without_allow_nil?
        model.validators.any? do |validator|
          validator.kind == :numericality &&
            Helper.check_inclusion?(validator.attributes, column.name) &&
            !validator.options[:allow_nil]
        end
      end

      def validator?(kind, attribute)
        model.validators.any? do |validator|
          validator.kind == kind && Helper.check_inclusion?(validator.attributes, attribute)
        end
      end

      def belongs_to_association
        @belongs_to_association ||= model.reflect_on_all_associations.find do |r|
          r.belongs_to? && Helper.check_inclusion?([r.foreign_key, r.foreign_type], column.name)
        end
      end
    end
  end
end
