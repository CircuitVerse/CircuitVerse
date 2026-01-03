# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks enum types consistency
    class EnumTypeChecker < EnumChecker
      Report = DatabaseConsistency::ReportBuilder.define(
        DatabaseConsistency::Report,
        :column_type,
        :values_types
      )

      private

      def preconditions
        column.present?
      end

      def check
        if valid?
          report_template(:ok)
        else
          report_template(:fail, error_slug: :inconsistent_enum_type)
        end
      end

      def report_template(status, error_slug: nil)
        Report.new(
          status: status,
          error_slug: error_slug,
          error_message: nil,
          column_type: column_type,
          values_types: values_types,
          **report_attributes
        )
      end

      def column_type_converter(type)
        case type
        when 'string', 'enum' then String
        when 'integer' then Integer
        when 'decimal' then BigDecimal
        when 'date' then Date
        when 'datetime' then DateTime
        when 'float' then Float
        else type
        end
      end

      def values_types
        model.defined_enums[enum].values.map(&:class).uniq
      end

      def column
        @column ||= model.columns.find { |c| c.name.to_s == enum.to_s }
      end

      def column_type
        column.type.to_s
      end

      # @return [Boolean]
      def valid?
        values_types.all? { |type| type == column_type_converter(column_type) }
      end
    end
  end
end
