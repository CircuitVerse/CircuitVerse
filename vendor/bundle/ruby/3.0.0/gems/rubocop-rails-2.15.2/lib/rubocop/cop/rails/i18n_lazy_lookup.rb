# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for places where I18n "lazy" lookup can be used.
      #
      # @example
      #   # en.yml
      #   # en:
      #   #   books:
      #   #     create:
      #   #       success: Book created!
      #
      #   # bad
      #   class BooksController < ApplicationController
      #     def create
      #       # ...
      #       redirect_to books_url, notice: t('books.create.success')
      #     end
      #   end
      #
      #   # good
      #   class BooksController < ApplicationController
      #     def create
      #       # ...
      #       redirect_to books_url, notice: t('.success')
      #     end
      #   end
      #
      class I18nLazyLookup < Base
        include VisibilityHelp
        extend AutoCorrector

        MSG = 'Use "lazy" lookup for the text used in controllers.'

        def_node_matcher :translate_call?, <<~PATTERN
          (send nil? {:translate :t} ${sym_type? str_type?} ...)
        PATTERN

        def on_send(node)
          translate_call?(node) do |key_node|
            key = key_node.value
            return if key.to_s.start_with?('.')

            controller, action = controller_and_action(node)
            return unless controller && action

            scoped_key = get_scoped_key(key_node, controller, action)
            return unless key == scoped_key

            add_offense(key_node) do |corrector|
              unscoped_key = key_node.value.to_s.split('.').last
              corrector.replace(key_node, "'.#{unscoped_key}'")
            end
          end
        end

        private

        def controller_and_action(node)
          action_node = node.each_ancestor(:def).first
          return unless action_node && node_visibility(action_node) == :public

          controller_node = node.each_ancestor(:class).first
          return unless controller_node && controller_node.identifier.source.end_with?('Controller')

          [controller_node, action_node]
        end

        def get_scoped_key(key_node, controller, action)
          path = controller_path(controller).tr('/', '.')
          action_name = action.method_name
          key = key_node.value.to_s.split('.').last

          "#{path}.#{action_name}.#{key}"
        end

        def controller_path(controller)
          module_name = controller.parent_module_name
          controller_name = controller.identifier.source

          path = if module_name == 'Object'
                   controller_name
                 else
                   "#{module_name}::#{controller_name}"
                 end

          path.delete_suffix('Controller').underscore
        end
      end
    end
  end
end
