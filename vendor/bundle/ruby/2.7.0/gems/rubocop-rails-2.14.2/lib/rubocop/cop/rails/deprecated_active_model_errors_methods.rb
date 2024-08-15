# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks direct manipulation of ActiveModel#errors as hash.
      # These operations are deprecated in Rails 6.1 and will not work in Rails 7.
      #
      # @safety
      #   This cop is unsafe because it can report `errors` manipulation on non-ActiveModel,
      #   which is obviously valid.
      #   The cop has no way of knowing whether a variable is an ActiveModel or not.
      #
      # @example
      #   # bad
      #   user.errors[:name] << 'msg'
      #   user.errors.messages[:name] << 'msg'
      #
      #   # good
      #   user.errors.add(:name, 'msg')
      #
      #   # bad
      #   user.errors[:name].clear
      #   user.errors.messages[:name].clear
      #
      #   # good
      #   user.errors.delete(:name)
      #
      class DeprecatedActiveModelErrorsMethods < Base
        MSG = 'Avoid manipulating ActiveModel errors as hash directly.'

        MANIPULATIVE_METHODS = Set[
          *%i[
            << append clear collect! compact! concat
            delete delete_at delete_if drop drop_while fill filter! keep_if
            flatten! insert map! pop prepend push reject! replace reverse!
            rotate! select! shift shuffle! slice! sort! sort_by! uniq! unshift
          ]
        ].freeze

        def_node_matcher :receiver_matcher_outside_model, '{send ivar lvar}'
        def_node_matcher :receiver_matcher_inside_model, '{nil? send ivar lvar}'

        def_node_matcher :any_manipulation?, <<~PATTERN
          {
            #root_manipulation?
            #root_assignment?
            #messages_details_manipulation?
            #messages_details_assignment?
          }
        PATTERN

        def_node_matcher :root_manipulation?, <<~PATTERN
          (send
            (send
              (send #receiver_matcher :errors) :[] ...)
            MANIPULATIVE_METHODS
            ...
          )
        PATTERN

        def_node_matcher :root_assignment?, <<~PATTERN
          (send
            (send #receiver_matcher :errors)
            :[]=
            ...)
        PATTERN

        def_node_matcher :messages_details_manipulation?, <<~PATTERN
          (send
            (send
              (send
                (send #receiver_matcher :errors)
                {:messages :details})
                :[]
                ...)
              MANIPULATIVE_METHODS
            ...)
        PATTERN

        def_node_matcher :messages_details_assignment?, <<~PATTERN
          (send
            (send
              (send #receiver_matcher :errors)
              {:messages :details})
            :[]=
            ...)
        PATTERN

        def on_send(node)
          any_manipulation?(node) do
            add_offense(node)
          end
        end

        private

        def receiver_matcher(node)
          model_file? ? receiver_matcher_inside_model(node) : receiver_matcher_outside_model(node)
        end

        def model_file?
          processed_source.buffer.name.include?('/models/')
        end
      end
    end
  end
end
