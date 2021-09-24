# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that `tag` is used instead of `content_tag`
      # because `content_tag` is legacy syntax.
      #
      # NOTE: Allow `content_tag` when the first argument is a variable because
      #      `content_tag(name)` is simpler rather than `tag.public_send(name)`.
      #
      # @example
      #  # bad
      #  content_tag(:p, 'Hello world!')
      #  content_tag(:br)
      #
      #  # good
      #  tag.p('Hello world!')
      #  tag.br
      #  content_tag(name, 'Hello world!')
      class ContentTag < Cop
        include RangeHelp
        extend TargetRailsVersion

        minimum_target_rails_version 5.1

        MSG = 'Use `tag` instead of `content_tag`.'

        def on_send(node)
          return unless node.method?(:content_tag)

          first_argument = node.first_argument
          return unless first_argument

          return if first_argument.variable? || first_argument.send_type? || first_argument.const_type?

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            if method_name?(node.first_argument)
              range = correction_range(node)

              rest_args = node.arguments.drop(1)
              replacement = "tag.#{node.first_argument.value.to_s.underscore}(#{rest_args.map(&:source).join(', ')})"

              corrector.replace(range, replacement)
            else
              corrector.replace(node.loc.selector, 'tag')
            end
          end
        end

        private

        def method_name?(node)
          return false unless node.str_type? || node.sym_type?

          /^[a-zA-Z_][a-zA-Z_\-0-9]*$/.match?(node.value)
        end

        def correction_range(node)
          range_between(node.loc.selector.begin_pos, node.loc.expression.end_pos)
        end
      end
    end
  end
end
