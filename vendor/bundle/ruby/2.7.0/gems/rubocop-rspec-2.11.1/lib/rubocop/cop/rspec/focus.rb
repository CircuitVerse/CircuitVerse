# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if examples are focused.
      #
      # @example
      #   # bad
      #   describe MyClass, focus: true do
      #   end
      #
      #   describe MyClass, :focus do
      #   end
      #
      #   fdescribe MyClass do
      #   end
      #
      #   # good
      #   describe MyClass do
      #   end
      class Focus < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Focused spec found.'

        # @!method focusable_selector?(node)
        def_node_matcher :focusable_selector?, <<-PATTERN
          {
            #ExampleGroups.regular
            #ExampleGroups.skipped
            #Examples.regular
            #Examples.skipped
            #Examples.pending
          }
        PATTERN

        # @!method metadata(node)
        def_node_matcher :metadata, <<-PATTERN
          {(send #rspec? #focusable_selector? <$(sym :focus) ...>)
           (send #rspec? #focusable_selector? ... (hash <$(pair (sym :focus) true) ...>))}
        PATTERN

        # @!method focused_block?(node)
        def_node_matcher :focused_block?,
                         send_pattern(<<~PATTERN)
                           {#ExampleGroups.focused #Examples.focused}
                         PATTERN

        def on_send(node)
          focus_metadata(node) do |focus|
            add_offense(focus) do |corrector|
              if focus.pair_type? || focus.str_type? || focus.sym_type?
                corrector.remove(with_surrounding(focus))
              elsif focus.send_type?
                correct_send(corrector, focus)
              end
            end
          end
        end

        private

        def focus_metadata(node, &block)
          yield(node) if focused_block?(node)

          metadata(node, &block)
        end

        def with_surrounding(focus)
          range_with_space = range_with_surrounding_space(
            range: focus.loc.expression,
            side: :left
          )

          range_with_surrounding_comma(range_with_space, :left)
        end

        def correct_send(corrector, focus)
          range = focus.loc.selector
          unfocused = focus.method_name.to_s.sub(/^f/, '')
          unless Examples.regular(unfocused) || ExampleGroups.regular(unfocused)
            return
          end

          corrector.replace(range,
                            range.source.sub(focus.method_name.to_s, unfocused))
        end
      end
    end
  end
end
