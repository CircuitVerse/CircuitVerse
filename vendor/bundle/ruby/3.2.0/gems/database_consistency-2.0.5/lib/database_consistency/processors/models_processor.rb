# frozen_string_literal: true

module DatabaseConsistency
  module Processors
    # The class to process models
    class ModelsProcessor < BaseProcessor
      private

      def check
        Helper.project_models(configuration).flat_map do |model|
          DebugContext.with(model: model.name) do
            enabled_checkers.flat_map do |checker_class|
              DebugContext.with(checker: checker_class) do
                checker = checker_class.new(model)
                checker.report_if_enabled?(configuration)
              end
            end
          end
        end.compact
      end
    end
  end
end
