#!ruby

require 'rbs'
require 'rbs/cli'

using Module.new {
  refine(Object) do
    def const_name(node)
      case node.type
      when :CONST
        node.children[0]
      when :COLON2
        base, name = node.children
        base = const_name(base)
        return unless base
        "#{base}::#{name}"
      end
    end

    def process_class_methods(node, decls:, comments:, context:)
      return false unless node.type == :ITER

      fcall = node.children[0]
      return false unless fcall.children[0] == :class_methods

      name = RBS::TypeName.new(name: :ClassMethods, namespace: RBS::Namespace.empty)
      mod = RBS::AST::Declarations::Module.new(
        name: name,
        type_params: RBS::AST::Declarations::ModuleTypeParams.empty,
        self_types: [],
        members: [],
        annotations: [],
        location: nil,
        comment: comments[node.first_lineno - 1]
      )

      decls.push mod

      each_node [node.children[1]] do |child|
        process child, decls: mod.members, comments: comments, context: RBS::Prototype::RB::Context.initial
      end

      true
    end

    def process_struct_new(node, decls:, comments:, context:)
      return unless node.type == :CDECL

      name, *_, rhs = node.children
      fields, body = struct_new(rhs)
      return unless fields

      type_name = RBS::TypeName.new(name: name, namespace: RBS::Namespace.empty)
      kls = RBS::AST::Declarations::Class.new(
        name: type_name,
        super_class: struct_as_superclass,
        type_params: RBS::AST::Declarations::ModuleTypeParams.empty,
        members: [],
        annotations: [],
        location: nil,
        comment: comments[node.first_lineno - 1],
      )
      decls.push kls

      fields.children.compact.each do |f|
        case f.type
        when :LIT, :STR
          kls.members << RBS::AST::Members::AttrAccessor.new(
            name: f.children.first,
            type: untyped,
            kind: :instance,
            ivar_name: false,
            annotations: [],
            location: nil,
            comment: nil,
          )
        end
      end

      if body
        each_node [body] do |child|
          process child, decls: kls.members, comments: comments, context: RBS::Prototype::RB::Context.initial
        end
      end

      true
    end

    def process_attr_internal(node, decls:, comments:, context:)
      case node.type
      when :FCALL, :VCALL
        args = node.children[1]&.children || []

        case node.children[0]
        when :attr_internal_reader
          args.each do |arg|
            if arg && (name = literal_to_symbol(arg))
              decls << RBS::AST::Members::AttrReader.new(
                name: name,
                ivar_name: :"@_#{name}",
                type: RBS::Types::Bases::Any.new(location: nil),
                kind: context.attribute_kind,
                location: nil,
                comment: comments[node.first_lineno - 1],
                annotations: []
              )
            end
          end
        when :attr_internal_writer
          args.each do |arg|
            if arg && (name = literal_to_symbol(arg))
              decls << RBS::AST::Members::AttrWriter.new(
                name: name,
                ivar_name: :"@_#{name}",
                type: RBS::Types::Bases::Any.new(location: nil),
                kind: context.attribute_kind,
                location: nil,
                comment: comments[node.first_lineno - 1],
                annotations: []
              )
            end
          end
        when :attr_internal_accessor, :attr_internal
          args.each do |arg|
            if arg && (name = literal_to_symbol(arg))
              decls << RBS::AST::Members::AttrAccessor.new(
                name: name,
                ivar_name: :"@_#{name}",
                type: RBS::Types::Bases::Any.new(location: nil),
                kind: context.attribute_kind,
                location: nil,
                comment: comments[node.first_lineno - 1],
                annotations: []
              )
            end
          end
        end
      end
    end

    def class_new_method_to_type(node)
      case node.type
      when :CALL
        recv, name, _args = node.children
        return unless name == :new

        klass = const_name(recv)
        return unless klass

        type_name = RBS::TypeName.new(name: klass, namespace: RBS::Namespace.empty)
        RBS::Types::ClassInstance.new(name: type_name, args: [], location: nil)
      end
    end

    def struct_new(node)
      case node.type
      when :CALL
        # ok
      when :ITER
        call, block = node.children
        return struct_new(call)&.tap do |r|
          r << block
        end
      else
        return
      end

      recv, method_name, args = node.children
      return unless method_name == :new
      return unless recv.type == :CONST || recv.type == :COLON3
      return unless recv.children.first == :Struct

      [args]
    end

    def struct_as_superclass
      name = RBS::TypeName.new(name: 'Struct', namespace: RBS::Namespace.root)
      RBS::AST::Declarations::Class::Super.new(name: name, args: ['untyped'], location: nil)
    end
  end
}

module PrototypeExt
  def process(...)
    process_class_methods(...) || process_struct_new(...) || process_attr_internal(...) || super
  end

  def literal_to_type(node)
    class_new_method_to_type(node) || super
  end
end

RBS::Prototype::RB.prepend PrototypeExt

RBS::CLI.new(stdout: STDOUT, stderr: STDERR).run(ARGV.dup)
