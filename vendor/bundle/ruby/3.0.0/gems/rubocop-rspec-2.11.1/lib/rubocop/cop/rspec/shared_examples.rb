# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Enforces use of string to titleize shared examples.
      #
      # @example
      #   # bad
      #   it_behaves_like :foo_bar_baz
      #   it_should_behave_like :foo_bar_baz
      #   shared_examples :foo_bar_baz
      #   shared_examples_for :foo_bar_baz
      #   include_examples :foo_bar_baz
      #
      #   # good
      #   it_behaves_like 'foo bar baz'
      #   it_should_behave_like 'foo bar baz'
      #   shared_examples 'foo bar baz'
      #   shared_examples_for 'foo bar baz'
      #   include_examples 'foo bar baz'
      #
      class SharedExamples < Base
        extend AutoCorrector

        # @!method shared_examples(node)
        def_node_matcher :shared_examples,
                         send_pattern(
                           '{#SharedGroups.all #Includes.all}'
                         )

        def on_send(node)
          shared_examples(node) do
            ast_node = node.first_argument
            next unless ast_node&.sym_type?

            checker = Checker.new(ast_node)
            add_offense(checker.node, message: checker.message) do |corrector|
              corrector.replace(checker.node, checker.preferred_style)
            end
          end
        end

        # :nodoc:
        class Checker
          MSG = 'Prefer %<prefer>s over `%<current>s` ' \
                'to titleize shared examples.'

          attr_reader :node

          def initialize(node)
            @node = node
          end

          def message
            format(MSG, prefer: preferred_style, current: symbol.inspect)
          end

          def preferred_style
            string = symbol.to_s.tr('_', ' ')
            wrap_with_single_quotes(string)
          end

          private

          def symbol
            node.value
          end

          def wrap_with_single_quotes(string)
            "'#{string}'"
          end
        end
      end
    end
  end
end
