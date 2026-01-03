# frozen_string_literal: true

require 'imagen/ast/parser'
require 'imagen/ast/builder'

module Imagen
  module Node
    # Abstract base class
    class Base
      attr_reader :ast_node,
                  :children,
                  :name

      def initialize
        @children = []
      end

      def human_name
        raise NotImplementedError
      end

      def build_from_ast(ast_node)
        tap { @ast_node = ast_node }
      end

      def empty_def?
        ast_node.children.last.nil?
      end

      def file_path
        ast_node.location.name.source_buffer.name
      end

      def first_line
        ast_node.location.first_line
      end

      def line_numbers
        (first_line..last_line).to_a
      end

      def last_line
        ast_node.location.last_line
      end

      def source
        source_lines.join("\n")
      end

      def source_lines_with_numbers
        (first_line..last_line).zip(source_lines)
      end

      def source_lines
        ast_node.location.expression.source_buffer.source_lines[
          first_line - 1,
          last_line
        ]
      end

      def find_all(matcher, ret = [])
        ret.tap do
          ret << self if matcher.call(self)
          children.each { |child| child.find_all(matcher, ret) }
        end
      end
    end

    # Root node for a given directory
    class Root < Base
      attr_reader :dir

      def build_from_file(path)
        Imagen::Visitor.traverse(Imagen::AST::Parser.parse_file(path), self)
      rescue Parser::SyntaxError => e
        warn "#{path}: #{e} #{e.message}"
        self
      end

      def build_from_dir(dir)
        @dir = dir
        list_files.each do |path|
          Imagen::Visitor.traverse(Imagen::AST::Parser.parse_file(path), self)
        rescue Parser::SyntaxError => e
          warn "#{path}: #{e} #{e.message}"
        end
        self
      end

      def build_from_ast(ast_node)
        Imagen::Visitor.traverse(ast_node, self)
        self
      end

      def human_name
        'root'
      end

      # TODO: fix wrong inheritance
      def file_path
        dir
      end

      def first_line
        nil
      end

      def last_line
        nil
      end

      def source
        nil
      end

      private

      def list_files
        return [dir] if File.file?(dir)

        Dir.glob("#{dir}/**/*.rb").reject { |path| path =~ Imagen::EXCLUDE_RE }
      end
    end

    # Represents a Ruby module
    class Module < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].children[1].to_s }
      end

      def human_name
        'module'
      end
    end

    # Represents a Ruby class
    class Class < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].children[1].to_s }
      end

      def human_name
        'class'
      end
    end

    # Represents a Ruby class method
    class CMethod < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[1].to_s }
      end

      def human_name
        'class method'
      end
    end

    # Represents a Ruby instance method
    class IMethod < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].to_s }
      end

      def human_name
        'instance method'
      end
    end

    # Represents a Ruby block
    class Block < Base
      def build_from_ast(_ast_node)
        super
        tap { @name = ['block', args_list].compact.join(' ') }
      end

      def human_name
        'block'
      end

      private

      def args_list
        arg_nodes = ast_node.children.find { |n| n.type == :args }.children
        arg_names = arg_nodes.map { |arg| arg.children[0] }
        return if arg_names.empty?

        "(#{arg_names.join(', ')})"
      end
    end
  end
end
