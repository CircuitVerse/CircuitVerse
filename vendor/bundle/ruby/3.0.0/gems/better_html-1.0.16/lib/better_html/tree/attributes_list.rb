require 'better_html/tree/attribute'

module BetterHtml
  module Tree
    class AttributesList
      def initialize(list)
        @list = list || []
      end

      def self.from_nodes(nodes)
        new(nodes&.map { |node| Tree::Attribute.from_node(node) })
      end

      def [](name)
        @list.find do |attribute|
          attribute.name == name.downcase
        end
      end

      def each(&block)
        @list.each(&block)
      end
    end
  end
end
