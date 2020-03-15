require 'ast'

module BetterHtml
  module Tree
    class Attribute
      attr_reader :node, :name_node, :equal_node, :value_node

      def initialize(node)
        @node = node
        @name_node, @equal_node, @value_node = *node if @node.type == :attribute
      end

      def self.from_node(node)
        new(node)
      end

      def erb?
        @node.type == :erb
      end

      def loc
        @node.loc
      end

      def name
        @name_node&.loc&.source&.downcase
      end

      def value
        parts = value_node.to_a.reject{ |node| node.is_a?(::AST::Node) && node.type == :quote }
        parts.map { |s| s.is_a?(::AST::Node) ? s.loc.source : CGI.unescapeHTML(s) }.join
      end
    end
  end
end
