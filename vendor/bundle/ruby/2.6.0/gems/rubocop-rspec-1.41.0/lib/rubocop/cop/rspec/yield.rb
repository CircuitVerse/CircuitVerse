# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # This cop checks for calling a block within a stub.
      #
      # @example
      #   # bad
      #   allow(foo).to receive(:bar) { |&block| block.call(1) }
      #
      #   # good
      #   expect(foo).to be(:bar).and_yield(1)
      class Yield < Cop
        include RangeHelp

        MSG = 'Use `.and_yield`.'

        def_node_search :method_on_stub?, '(send nil? :receive ...)'

        def_node_matcher :block_arg, '(args (blockarg $_))'

        def_node_matcher :block_call?, '(send (lvar %) :call ...)'

        def on_block(node)
          return unless method_on_stub?(node.send_node)

          block_arg(node.arguments) do |block|
            if calling_block?(node.body, block)
              add_offense(node, location: block_range(node))
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            node_range = range_with_surrounding_space(
              range: block_range(node), side: :left
            )
            corrector.replace(node_range, generate_replacement(node.body))
          end
        end

        private

        def calling_block?(node, block)
          if node.begin_type?
            node.each_child_node.all? { |child| block_call?(child, block) }
          else
            block_call?(node, block)
          end
        end

        def block_range(node)
          node.loc.begin.with(end_pos: node.loc.end.end_pos)
        end

        def generate_replacement(node)
          if node.begin_type?
            node.children.map { |child| convert_block_to_yield(child) }.join
          else
            convert_block_to_yield(node)
          end
        end

        def convert_block_to_yield(node)
          args = node.arguments
          replacement = '.and_yield'
          replacement += "(#{args.map(&:source).join(', ')})" if args.any?
          replacement
        end
      end
    end
  end
end
