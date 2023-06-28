# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of exit statements (namely `return`,
      # `break` and `throw`) in transactions. This is due to the eventual
      # unexpected behavior when using ActiveRecord >= 7, where transactions
      # exitted using these statements are being rollbacked rather than
      # committed (pre ActiveRecord 7 behavior).
      #
      # As alternatives, it would be more intuitive to explicitly raise an
      # error when rollback is desired, and to use `next` when commit is
      # desired.
      #
      # @example
      #   # bad
      #   ApplicationRecord.transaction do
      #     return if user.active?
      #   end
      #
      #   # bad
      #   ApplicationRecord.transaction do
      #     break if user.active?
      #   end
      #
      #   # bad
      #   ApplicationRecord.transaction do
      #     throw if user.active?
      #   end
      #
      #   # good
      #   ApplicationRecord.transaction do
      #     # Rollback
      #     raise "User is active" if user.active?
      #   end
      #
      #   # good
      #   ApplicationRecord.transaction do
      #     # Commit
      #     next if user.active?
      #   end
      #
      # @see https://github.com/rails/rails/commit/15aa4200e083
      class TransactionExitStatement < Base
        MSG = <<~MSG.chomp
          Exit statement `%<statement>s` is not allowed. Use `raise` (rollback) or `next` (commit).
        MSG

        RESTRICT_ON_SEND = %i[transaction].freeze

        def_node_search :exit_statements, <<~PATTERN
          ({return | break | send nil? :throw} ...)
        PATTERN

        def on_send(node)
          return unless (parent = node.parent)
          return unless parent.block_type? && parent.body

          exit_statements(parent.body).each do |statement_node|
            next if in_rescue?(statement_node) || nested_block?(statement_node)

            statement = statement(statement_node)
            message = format(MSG, statement: statement)

            add_offense(statement_node, message: message)
          end
        end

        private

        def statement(statement_node)
          if statement_node.return_type?
            'return'
          elsif statement_node.break_type?
            'break'
          else
            statement_node.method_name
          end
        end

        def in_rescue?(statement_node)
          statement_node.ancestors.find(&:rescue_type?)
        end

        def nested_block?(statement_node)
          return false unless statement_node.break_type?

          !statement_node.ancestors.find(&:block_type?).method?(:transaction)
        end
      end
    end
  end
end
