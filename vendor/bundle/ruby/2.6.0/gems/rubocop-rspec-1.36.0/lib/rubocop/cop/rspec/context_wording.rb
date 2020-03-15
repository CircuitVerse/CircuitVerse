# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks that `context` docstring starts with an allowed prefix.
      #
      # @see https://github.com/reachlocal/rspec-style-guide#context-descriptions
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
      class ContextWording < Cop
        MSG = 'Start context description with %<prefixes>s.'

        def_node_matcher :context_wording, <<-PATTERN
          (block (send #{RSPEC} { :context :shared_context } $(str #bad_prefix?) ...) ...)
        PATTERN

        def on_block(node)
          context_wording(node) do |context|
            add_offense(context,
                        message: format(MSG, prefixes: joined_prefixes))
          end
        end

        private

        def bad_prefix?(description)
          !prefixes.include?(description.split.first)
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
      end
    end
  end
end
