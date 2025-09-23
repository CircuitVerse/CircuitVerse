# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks the database enum values and ActiveRecord's enum values/inclusion validations are aligned
    class EnumValueChecker < ColumnChecker
      Report = ReportBuilder.define(
        DatabaseConsistency::Report,
        :enum_values,
        :declared_values
      )

      private

      def report_template(status, declared_values, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          enum_values: enum_column_values,
          declared_values: declared_values,
          **report_attributes
        )
      end

      def preconditions
        Helper.postgresql? && ActiveRecord::VERSION::MAJOR >= 7 && column.type == :enum && (enum || inclusion_validator)
      end

      def check
        [
          (verify_enum if enum),
          (verify_inclusion_validator if inclusion_validator)
        ].compact
      end

      def enum_column_values # rubocop:disable Metrics/AbcSize
        @enum_column_values ||=
          if model.connection.enum_types.is_a?(Array)
            _, values = model.connection.enum_types.find { |(enum, _)| enum == column.sql_type }
            case values
            when Array then values
            else
              values.split(',').map(&:strip)
            end
          else
            # active_record-postgres_enum gem
            model.connection.enum_types[column.sql_type.to_sym]
          end
      end

      def verify_enum
        values = enum.values.uniq

        if enum_column_values.sort == values.sort
          report_template(:ok, values)
        else
          report_template(:fail, values, error_slug: :enum_values_inconsistent_with_ar_enum)
        end
      end

      def verify_inclusion_validator
        values = validator_values(inclusion_validator).uniq

        if enum_column_values.sort == values.sort
          report_template(:ok, values)
        else
          report_template(:fail, values, error_slug: :enum_values_inconsistent_with_inclusion)
        end
      end

      def validator_values(validator)
        validator.options[:in] || validator.options[:within]
      end

      def simple_values_validator?(validator)
        values = validator_values(validator)

        values.is_a?(Array) && values.all? { |val| val.is_a?(String) }
      end

      def inclusion_validator
        @inclusion_validator ||= model.validators.find do |validator|
          validator.kind == :inclusion &&
            Helper.check_inclusion?(validator.attributes, column.name) &&
            simple_values_validator?(validator)
        end
      end

      def enum
        @enum ||= model.defined_enums[column.name]
      end
    end
  end
end
