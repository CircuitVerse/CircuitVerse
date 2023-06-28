# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      module Rails
        # Checks that tests use RSpec `before` hook over Rails `setup` method.
        #
        # @example
        #
        #   # bad
        #   setup do
        #     allow(foo).to receive(:bar)
        #   end
        #
        #   # good
        #   before do
        #     allow(foo).to receive(:bar)
        #   end
        #
        class AvoidSetupHook < Base
          extend AutoCorrector

          MSG = 'Use `before` instead of `setup`.'

          # @!method setup_call(node)
          def_node_matcher :setup_call, <<-PATTERN
            (block
              $(send nil? :setup)
              (args) _)
          PATTERN

          def on_block(node)
            setup_call(node) do |setup|
              add_offense(node) do |corrector|
                corrector.replace setup, 'before'
              end
            end
          end
        end
      end
    end
  end
end
