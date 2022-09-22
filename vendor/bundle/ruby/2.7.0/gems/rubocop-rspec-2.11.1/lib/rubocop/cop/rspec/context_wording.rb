# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that `context` docstring starts with an allowed prefix.
      #
      # The default list of prefixes is minimal. Users are encouraged to tailor
      # the configuration to meet project needs. Other acceptable prefixes may
      # include `if`, `unless`, `for`, `before`, `after`, or `during`.
      # They may consist of multiple words if desired.
      #
      # @see https://rspec.rubystyle.guide/#context-descriptions
      # @see http://www.betterspecs.org/#contexts
      #
      # @example `Prefixes` configuration
      #
      #   # .rubocop.yml
      #   # RSpec/ContextWording:
      #   #   Prefixes:
      #   #     - when
      #   #     - with
      #   #     - without
      #   #     - if
      #   #     - unless
      #   #     - for
      #
      # @example
      #   # bad
      #   context 'the display name not present' do
      #     # ...
      #   end
      #
      #   # good
      #   context 'when the display name is not present' do
      #     # ...
      #   end
      class ContextWording < Base
        MSG = 'Start context description with %<prefixes>s.'

        # @!method context_wording(node)
        def_node_matcher :context_wording, <<-PATTERN
          (block (send #rspec? { :context :shared_context } $(str #bad_prefix?) ...) ...)
        PATTERN

        def on_block(node)
          context_wording(node) do |context|
            add_offense(context,
                        message: format(MSG, prefixes: joined_prefixes))
          end
        end

        private

        def bad_prefix?(description)
          !prefix_regex.match?(description)
        end

        def joined_prefixes
          quoted = prefixes.map { |prefix| "'#{prefix}'" }
          return quoted.first if quoted.size == 1

          quoted << "or #{quoted.pop}"
          quoted.join(', ')
        end

        def prefixes
          cop_config['Prefixes'] || []
        end

        def prefix_regex
          /^#{Regexp.union(prefixes)}\b/
        end
      end
    end
  end
end
