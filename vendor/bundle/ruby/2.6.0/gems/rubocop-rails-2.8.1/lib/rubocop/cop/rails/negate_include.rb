# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the use of `collection.exclude?(obj)`
      # over `!collection.include?(obj)`.
      #
      # @example
      #   # bad
      #   !array.include?(2)
      #   !hash.include?(:key)
      #
      #   # good
      #   array.exclude?(2)
      #   hash.exclude?(:key)
      #
      class NegateInclude < Cop
        MSG = 'Use `.exclude?` and remove the negation part.'

        def_node_matcher :negate_include_call?, <<~PATTERN
          (send (send $_ :include? $_) :!)
        PATTERN

        def on_send(node)
          add_offense(node) if negate_include_call?(node)
        end

        def autocorrect(node)
          negate_include_call?(node) do |receiver, obj|
            lambda do |corrector|
              corrector.replace(node, "#{receiver.source}.exclude?(#{obj.source})")
            end
          end
        end
      end
    end
  end
end
