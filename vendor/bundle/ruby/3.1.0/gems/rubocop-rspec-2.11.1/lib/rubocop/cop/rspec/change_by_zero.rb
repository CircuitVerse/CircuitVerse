# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Prefer negated matchers over `to change.by(0)`.
      #
      # @example
      #   # bad
      #   expect { run }.to change(Foo, :bar).by(0)
      #   expect { run }.to change { Foo.bar }.by(0)
      #   expect { run }
      #     .to change(Foo, :bar).by(0)
      #     .and change(Foo, :baz).by(0)
      #   expect { run }
      #     .to change { Foo.bar }.by(0)
      #     .and change { Foo.baz }.by(0)
      #
      #   # good
      #   expect { run }.not_to change(Foo, :bar)
      #   expect { run }.not_to change { Foo.bar }
      #   expect { run }
      #     .to not_change(Foo, :bar)
      #     .and not_change(Foo, :baz)
      #   expect { run }
      #     .to not_change { Foo.bar }
      #     .and not_change { Foo.baz }
      #
      class ChangeByZero < Base
        extend AutoCorrector
        MSG = 'Prefer `not_to change` over `to change.by(0)`.'
        MSG_COMPOUND = 'Prefer negated matchers with compound expectations ' \
                          'over `change.by(0)`.'
        RESTRICT_ON_SEND = %i[change].freeze

        # @!method expect_change_with_arguments(node)
        def_node_matcher :expect_change_with_arguments, <<-PATTERN
          (send
            (send nil? :change ...) :by
            (int 0))
        PATTERN

        # @!method expect_change_with_block(node)
        def_node_matcher :expect_change_with_block, <<-PATTERN
          (send
            (block
              (send nil? :change)
              (args)
              (send (...) $_)) :by
            (int 0))
        PATTERN

        def on_send(node)
          expect_change_with_arguments(node.parent) do
            check_offence(node.parent)
          end

          expect_change_with_block(node.parent.parent) do
            check_offence(node.parent.parent)
          end
        end

        private

        def check_offence(node)
          expression = node.loc.expression
          if compound_expectations?(node)
            add_offense(expression, message: MSG_COMPOUND)
          else
            add_offense(expression) do |corrector|
              autocorrect(corrector, node)
            end
          end
        end

        def compound_expectations?(node)
          %i[and or].include?(node.parent.method_name)
        end

        def autocorrect(corrector, node)
          corrector.replace(node.parent.loc.selector, 'not_to')
          range = node.loc.dot.with(end_pos: node.loc.expression.end_pos)
          corrector.remove(range)
        end
      end
    end
  end
end
