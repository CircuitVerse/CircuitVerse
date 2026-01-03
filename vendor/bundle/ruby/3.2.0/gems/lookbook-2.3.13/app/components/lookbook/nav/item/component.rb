module Lookbook
  class Nav::Item::Component < Lookbook::BaseComponent
    delegate :label, :depth, :priority, to: :node

    attr_reader :node, :nav_id

    def initialize(node, nav_id:, **html_attrs)
      @node = node
      @nav_id = nav_id
      super(**html_attrs)
    end

    def id
      "#{nav_id}-#{node.id}"
    end

    def left_pad
      depth * 12
    end

    def children
      @children ||= node.sort.map { |node| render_item(node) }
    end

    def nav_icon
      :folder
    end

    def children?
      children.any?
    end

    def render_item(node)
      item_class = (node.type == :directory) ? Nav::Directory::Component : Nav::Entity::Component
      lookbook_render item_class.new node, nav_id: nav_id
    end

    protected

    def alpine_data
      alpine_encode({id: node.id, matchers: []})
    end

    def alpine_component
      "navItemComponent"
    end
  end
end
