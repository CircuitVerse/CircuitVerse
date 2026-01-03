# frozen_string_literal: true

module Imagen
  # AST Traversal that calls respective builder methods from Imagen::Node
  class Visitor
    TYPES = {
      block: Imagen::Node::Block,
      class: Imagen::Node::Class,
      def: Imagen::Node::IMethod,
      defs: Imagen::Node::CMethod,
      module: Imagen::Node::Module
    }.freeze

    attr_reader :root, :current_root, :file_path

    def self.traverse(ast, root)
      new.traverse(ast, root)
      root
    end

    def traverse(ast_node, parent)
      return unless ast_node.is_a?(Parser::AST::Node)

      node = visit(ast_node, parent)
      ast_node.children.each { |child| traverse(child, node || parent) }
    end

    # This method reeks of :reek:UtilityFunction
    def visit(ast_node, parent)
      klass = TYPES[ast_node.type] || return
      klass.new.build_from_ast(ast_node).tap do |node|
        parent.children << node
      end
    end
  end
end
