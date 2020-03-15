# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for redundant `location` argument to `#add_offense`. `location`
      # argument has a default value of `:expression` and this method will
      # automatically use it.
      #
      # @example
      #
      #   # bad
      #   add_offense(node, location: :expression)
      #
      #   # good
      #   add_offense(node)
      #   add_offense(node, location: :selector)
      #
      class RedundantLocationArgument < Cop
        include RangeHelp

        MSG = 'Redundant location argument to `#add_offense`.'

        def_node_matcher :redundant_location_argument, <<~PATTERN
          (send nil? :add_offense _
            (hash <$(pair (sym :location) (sym :expression)) ...>)
          )
        PATTERN

        def on_send(node)
          redundant_location_argument(node) { |argument| add_offense(argument) }
        end

        def autocorrect(node)
          range = offending_range(node)

          ->(corrector) { corrector.remove(range) }
        end

        def offending_range(node)
          with_space = range_with_surrounding_space(range: node.loc.expression)

          range_with_surrounding_comma(with_space, :left)
        end
      end
    end
  end
end
