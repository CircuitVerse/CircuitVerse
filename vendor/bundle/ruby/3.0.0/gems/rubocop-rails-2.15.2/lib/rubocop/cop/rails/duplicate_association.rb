# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Looks for associations that have been defined multiple times in the same file.
      #
      # When an association is defined multiple times on a model, Active Record overrides the
      # previously defined association with the new one. Because of this, this cop's autocorrection
      # simply keeps the last of any duplicates and discards the rest.
      #
      # @example
      #
      #   # bad
      #   belongs_to :foo
      #   belongs_to :bar
      #   has_one :foo
      #
      #   # good
      #   belongs_to :bar
      #   has_one :foo
      #
      class DuplicateAssociation < Base
        include RangeHelp
        extend AutoCorrector
        include ClassSendNodeHelper

        MSG = "Association `%<name>s` is defined multiple times. Don't repeat associations."

        def_node_matcher :association, <<~PATTERN
          (send nil? {:belongs_to :has_one :has_many :has_and_belongs_to_many} ({sym str} $_) ...)
        PATTERN

        def on_class(class_node)
          offenses(class_node).each do |name, nodes|
            nodes.each do |node|
              add_offense(node, message: format(MSG, name: name)) do |corrector|
                next if same_line?(nodes.last, node)

                corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
              end
            end
          end
        end

        private

        def offenses(class_node)
          class_send_nodes(class_node).select { |node| association(node) }
                                      .group_by { |node| association(node).to_sym }
                                      .select { |_, nodes| nodes.length > 1 }
        end
      end
    end
  end
end
