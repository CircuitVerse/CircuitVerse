# frozen_string_literal: true

module DatabaseConsistency
  module Checkers
    # This class checks redundant case_sensitive option for uniqueness validation
    class CaseSensitiveUniqueValidationChecker < ValidatorChecker
      private

      def preconditions
        validator.kind == :uniqueness && Helper.postgresql? && citext?
      end

      def check
        if validator.options[:case_sensitive].nil? || validator.options[:case_sensitive]
          report_template(:ok)
        else
          report_template(:fail, error_slug: :redundant_case_insensitive_option)
        end
      end

      def citext?
        field_name = Helper.foreign_key_or_attribute(model, attribute)

        field = model.columns.find { |column| column.name.to_s == field_name.to_s }

        field&.type == :citext
      end

      def sorted_uniqueness_validator_columns
        @sorted_uniqueness_validator_columns ||= Helper.sorted_uniqueness_validator_columns(attribute, validator, model)
      end
    end
  end
end
