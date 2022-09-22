# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps determine the offending location if there is not an empty line
      # following the node. Allows comments to follow directly after.
      module EmptyLineSeparation
        include FinalEndLocation
        include RangeHelp

        def missing_separating_line_offense(node)
          return if last_child?(node)

          missing_separating_line(node) do |location|
            msg = yield(node.method_name)
            add_offense(location, message: msg) do |corrector|
              corrector.insert_after(location.end, "\n")
            end
          end
        end

        def missing_separating_line(node)
          line = final_end_location(node).line

          line += 1 while comment_line?(processed_source[line])

          return if processed_source[line].blank?

          yield offending_loc(line)
        end

        def offending_loc(last_line)
          offending_line = processed_source[last_line - 1]

          content_length = offending_line.lstrip.length
          start          = offending_line.length - content_length

          source_range(processed_source.buffer,
                       last_line, start, content_length)
        end

        def last_child?(node)
          return true unless node.parent&.begin_type?

          node.equal?(node.parent.children.last)
        end
      end
    end
  end
end
