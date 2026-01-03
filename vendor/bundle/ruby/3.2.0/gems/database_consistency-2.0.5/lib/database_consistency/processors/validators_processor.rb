# frozen_string_literal: true

module DatabaseConsistency
  module Processors
    # The class to process validators
    class ValidatorsProcessor < BaseProcessor
      private

      # @return [Array<Hash>]
      def check # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Helper.parent_models(configuration).flat_map do |model|
          DebugContext.with(model: model.name) do
            model.validators.flat_map do |validator|
              next unless validator.respond_to?(:attributes)

              validator.attributes.flat_map do |attribute|
                DebugContext.with(attribute: attribute) do
                  enabled_checkers.flat_map do |checker_class|
                    DebugContext.with(checker: checker_class) do
                      checker = checker_class.new(model, attribute, validator)
                      checker.report_if_enabled?(configuration)
                    end
                  end
                end
              end
            end
          end
        end.compact
      end
    end
  end
end
