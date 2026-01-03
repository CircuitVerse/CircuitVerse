module Lookbook
  class PageTreeBuilder < Service
    attr_reader :include_hidden

    def initialize(pages, include_hidden: false)
      @pages = pages.to_a
      @include_hidden = include_hidden
    end

    def call
      root_node = TreeNode.new
      pages.each do |page|
        current_node = root_node

        path_segments = parse_segments(page.relative_file_path)
        path_segments.each.with_index(1) do |segment, i|
          name, priority_prefix = segment
          content = page if page.depth == i # pages are always on the leaf nodes

          current_node.add_child(name, content, priority: priority_prefix) unless current_node.has_child?(name)
          current_node = current_node.get_child(name)
        end
      end
      root_node
    end

    def parse_segments(path)
      path.to_s.split("/").map do |segment|
        unless segment.start_with?(".")
          priority, name = PriorityPrefixParser.call(segment)
          [name, priority || 10000]
        end
      end.compact
    end

    def pages
      include_hidden ? @pages : @pages.select(&:visible?)
    end
  end
end
