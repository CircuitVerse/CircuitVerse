# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of `pluck` over `map`.
      #
      # `pluck` can be used instead of `map` to extract a single key from each
      # element in an enumerable. When called on an Active Record relation, it
      # results in a more efficient query that only selects the necessary key.
      #
      # @example
      #   # bad
      #   Post.published.map { |post| post[:title] }
      #   [{ a: :b, c: :d }].collect { |el| el[:a] }
      #
      #   # good
      #   Post.published.pluck(:title)
      #   [{ a: :b, c: :d }].pluck(:a)
      class Pluck < Base
        extend AutoCorrector
        extend TargetRailsVersion

        MSG = 'Prefer `pluck(:%<value>s)` over `%<current>s`.'

        minimum_target_rails_version 5.0

        def_node_matcher :pluck_candidate?, <<~PATTERN
          ({block numblock} (send _ {:map :collect}) $_argument (send (lvar $_element) :[] (sym $_value)))
        PATTERN

        def on_block(node)
          pluck_candidate?(node) do |argument, element, value|
            match = if node.block_type?
                      argument.children.first.source.to_sym == element
                    else # numblock
                      argument == 1 && element == :_1
                    end
            next unless match

            message = message(value, node)

            add_offense(offense_range(node), message: message) do |corrector|
              corrector.replace(offense_range(node), "pluck(:#{value})")
            end
          end
        end
        alias on_numblock on_block

        private

        def offense_range(node)
          node.send_node.loc.selector.join(node.loc.end)
        end

        def message(value, node)
          current = offense_range(node).source

          format(MSG, value: value, current: current)
        end
      end
    end
  end
end
