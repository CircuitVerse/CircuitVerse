# frozen_string_literal: true

module DatabaseConsistency
  module Processors
    # The class to process validators
    class ValidatorsFractionsProcessor < BaseProcessor
      private

      # @return [Array<Hash>]
      def check # rubocop:disable Metrics/MethodLength
        Helper.parent_models(configuration).flat_map do |model|
          DebugContext.with(model: model.name) do
            model._validators.flat_map do |attribute, validators|
              DebugContext.with(attribute: attribute) do
                next unless attribute

                enabled_checkers.flat_map do |checker_class|
                  DebugContext.with(checker: checker_class) do
                    checker = checker_class.new(model, attribute, validators)
                    checker.report_if_enabled?(configuration)
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
