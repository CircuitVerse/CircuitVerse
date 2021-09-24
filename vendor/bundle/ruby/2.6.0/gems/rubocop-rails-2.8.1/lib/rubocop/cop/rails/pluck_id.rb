# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the use of `ids` over `pluck(:id)` and `pluck(primary_key)`.
      #
      # @example
      #   # bad
      #   User.pluck(:id)
      #   user.posts.pluck(:id)
      #
      #   def self.user_ids
      #     pluck(primary_key)
      #   end
      #
      #   # good
      #   User.ids
      #   user.posts.ids
      #
      #   def self.user_ids
      #     ids
      #   end
      #
      class PluckId < Cop
        include RangeHelp
        include ActiveRecordHelper

        MSG = 'Use `ids` instead of `%<bad_method>s`.'

        def_node_matcher :pluck_id_call?, <<~PATTERN
          (send _ :pluck {(sym :id) (send nil? :primary_key)})
        PATTERN

        def on_send(node)
          return if !pluck_id_call?(node) || in_where?(node)

          range = offense_range(node)
          message = format(MSG, bad_method: range.source)

          add_offense(node, location: range, message: message)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(offense_range(node), 'ids')
          end
        end

        private

        def offense_range(node)
          range_between(node.loc.selector.begin_pos, node.loc.expression.end_pos)
        end
      end
    end
  end
end
