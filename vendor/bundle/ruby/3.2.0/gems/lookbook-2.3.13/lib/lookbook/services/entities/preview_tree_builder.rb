module Lookbook
  class PreviewTreeBuilder < Service
    attr_reader :include_hidden

    def initialize(previews, include_hidden: false)
      @previews = previews.to_a
      @include_hidden = include_hidden
    end

    def call
      root_node = TreeNode.new
      previews.each do |preview|
        current_node = root_node

        path_segments = preview.logical_path.split("/")
        path_segments.each.with_index(1) do |name, i|
          content = preview if preview.depth == i # entities are always on the leaf nodes

          current_node.add_child(name, content) unless current_node.has_child?(name)
          current_node = current_node.get_child(name)

          content&.visible_scenarios&.each do |scenario|
            current_node.add_child(scenario.name, scenario)
          end
        end
      end
      root_node
    end

    def previews
      include_hidden ? @previews : @previews.select(&:visible?)
    end
  end
end
