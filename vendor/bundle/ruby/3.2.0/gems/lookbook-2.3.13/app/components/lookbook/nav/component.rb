module Lookbook
  class Nav::Component < Lookbook::BaseComponent
    renders_one :filter, Lookbook::Filter::Component
    renders_one :toolbar, Lookbook::Toolbar::Component

    attr_reader :id, :tree

    def initialize(tree:, id: nil, **attrs)
      @id = id
      @tree = tree
      super(**attrs, id: id)
    end

    def items
      @items ||= tree.map do |node|
        item_class = (node.type == :directory) ? Nav::Directory::Component : Nav::Entity::Component
        lookbook_render item_class.new node, nav_id: id
      end
    end

    protected

    def alpine_component
      "navComponent"
    end
  end
end
