# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for long examples.
      #
      # A long example is usually more difficult to understand. Consider
      # extracting out some behaviour, e.g. with a `let` block, or a helper
      # method.
      #
      # @example
      #   # bad
      #   it do
      #     service = described_class.new
      #     more_setup
      #     more_setup
      #     result = service.call
      #     expect(result).to be(true)
      #   end
      #
      #   # good
      #   it do
      #     service = described_class.new
      #     result = service.call
      #     expect(result).to be(true)
      #   end
      #
      # You can set literals you want to fold with `CountAsOne`.
      # Available are: 'array', 'hash', and 'heredoc'. Each literal
      # will be counted as one line regardless of its actual size.
      #
      # @example CountAsOne: ['array', 'heredoc']
      #
      #   it do
      #     array = [         # +1
      #       1,
      #       2
      #     ]
      #
      #     hash = {          # +3
      #       key: 'value'
      #     }
      #
      #     msg = <<~HEREDOC  # +1
      #       Heredoc
      #       content.
      #     HEREDOC
      #   end                 # 5 points
      class ExampleLength < Base
        include CodeLength

        LABEL = 'Example'

        def on_block(node)
          return unless example?(node)

          check_code_length(node)
        end

        private

        def cop_label
          LABEL
        end
      end
    end
  end
end
