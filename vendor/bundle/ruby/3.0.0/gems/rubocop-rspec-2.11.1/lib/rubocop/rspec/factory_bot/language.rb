# frozen_string_literal: true

module RuboCop
  module RSpec
    module FactoryBot
      # Contains node matchers for common FactoryBot DSL.
      module Language
        extend RuboCop::NodePattern::Macros

        # @!method factory_bot?(node)
        def_node_matcher :factory_bot?, <<~PATTERN
          (const {nil? cbase} {:FactoryGirl :FactoryBot})
        PATTERN
      end
    end
  end
end
