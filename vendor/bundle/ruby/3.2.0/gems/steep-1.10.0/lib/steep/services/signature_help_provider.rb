module Steep
  module Services
    class SignatureHelpProvider
      MethodCall = TypeInference::MethodCall

      Item = _ = Struct.new(:method_type, :comment, :active_parameter) do
        # @implements Item

        def parameters
          if method_type.type.is_a?(RBS::Types::Function)
            arguments = [] #: Array[String]
            arguments.push(*method_type.type.required_positionals.map(&:to_s))
            arguments.push(*method_type.type.optional_positionals.map {|p| "?#{p}"})
            arguments.push("*#{method_type.type.rest_positionals}") if method_type.type.rest_positionals
            arguments.push(*method_type.type.trailing_positionals.map(&:to_s))
            arguments.push(*method_type.type.required_keywords.map {|name, param| "#{name}: #{param}" })
            arguments.push(*method_type.type.optional_keywords.map {|name, param| "?#{name}: #{param}" })
            arguments.push("**#{method_type.type.rest_keywords}") if method_type.type.rest_keywords
            arguments
          end
        end
      end

      include NodeHelper

      attr_reader :source, :path, :subtyping, :typing, :buffer

      def env
        subtyping.factory.env
      end

      def initialize(source:, subtyping:)
        @source = source
        @subtyping = subtyping
        @buffer = source.buffer
      end

      def run(line:, column:)
        nodes = source.find_nodes(line: line, column: column)

        return unless nodes

        typing = type_check!(line: line, column: column)
        argument_nodes = [] #: Array[Parser::AST::Node]

        while true
          node = nodes.shift()
          parent = nodes.first

          node or return
          argument_nodes << node

          if node.type == :send || node.type == :csend
            pos = buffer.loc_to_pos([line, column])
            begin_loc = (_ = node.loc).begin #: Parser::Source::Range?
            end_loc = (_ = node.loc).end #: Parser::Source::Range?

            if begin_loc && end_loc
              if begin_loc.end_pos <= pos && pos <= end_loc.begin_pos
                # Given position is between open/close parens of args of send node

                if parent && (parent.type == :block || parent.type == :numblock) && node.equal?(parent.children[0])
                  send_node = parent
                else
                  send_node = node
                end

                last_argument_nodes = last_argument_nodes_for(argument_nodes: argument_nodes, line: line, column: column)
                return signature_help_for(send_node, argument_nodes, last_argument_nodes, typing)
              end
            end
          end
        end
      end

      def type_check!(line:, column:)
        source = self.source.without_unrelated_defs(line: line, column: column)
        resolver = RBS::Resolver::ConstantResolver.new(builder: subtyping.factory.definition_builder)
        pos = self.source.buffer.loc_to_pos([line, column])
        TypeCheckService.type_check(source: source, subtyping: subtyping, constant_resolver: resolver, cursor: pos)
      end

      def last_argument_nodes_for(argument_nodes:, line:, column:)
        last = argument_nodes.last or raise
        return unless last.children[2]  # No arguments
        return argument_nodes if argument_nodes.size > 1  # Cursor is on the last argument

        pos = buffer.loc_to_pos([line, column])

        while true
          pos -= 1
          line, column = buffer.pos_to_loc(pos)
          nodes = source.find_nodes(line: line, column: column)
          return unless nodes

          index = nodes.index { |n| n.type == :send || n.type == :csend }
          return nodes[..index] if index.to_i > 0
        end
      end

      def signature_help_for(node, argument, last_argument, typing)
        call = typing.call_of(node: node)
        context = typing.cursor_context.context or raise

        items = [] #: Array[Item]
        index = nil #: Integer?

        case call
        when MethodCall::Typed, MethodCall::Error
          type = call.receiver_type
          config = Interface::Builder::Config.new(self_type: context.self_type, variable_bounds: context.variable_context.upper_bounds)

          if shape = subtyping.builder.shape(type, config)
            shape = shape.public_shape if private_send?(node)

            if method = shape.methods[call.method_name]
              method.overloads.each.with_index do |overload, i|
                defn = overload.method_defs[0]

                active_parameter = active_parameter_for(defn&.type, argument, last_argument, node)
                items << Item.new(subtyping.factory.method_type_1(overload.method_type), defn&.comment, active_parameter)

                if call.is_a?(MethodCall::Typed)
                  if call.method_decls.intersect?(overload.method_decls(call.method_name).to_set)
                    index = i
                  end
                end
              end
            end
          end
        when MethodCall::Untyped, MethodCall::NoMethodError
          return
        end

        [items, index]
      end

      def active_parameter_for(method_type, argument_nodes, last_argument_nodes, node)
        return unless method_type
        return unless method_type.type.is_a?(RBS::Types::Function)

        positionals = method_type.type.required_positionals.size + method_type.type.optional_positionals.size + (method_type.type.rest_positionals ? 1 : 0) + method_type.type.trailing_positionals.size

        if argument_nodes.size == 1
          # Cursor is not on the argument (maybe on comma after argument)
          return 0 if last_argument_nodes.nil?  # No arguments

          case last_argument_nodes.fetch(-2).type
          when :splat
            method_type.type.required_positionals.size + method_type.type.optional_positionals.size + 1 if method_type.type.rest_positionals
          when :kwargs
            case last_argument_nodes.fetch(-3).type
            when :pair
              argname = last_argument_nodes.fetch(-3).children.first.children.first
              if method_type.type.required_keywords.key?(argname)
                positionals + method_type.type.required_keywords.keys.index(argname).to_i + 1
              elsif method_type.type.optional_keywords.key?(argname)
                positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.keys.index(argname).to_i + 1
              elsif method_type.type.rest_keywords
                positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.size
              end
            when :kwsplat
              positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.size if method_type.type.rest_keywords
            end
          else
            pos = (node.children[2...] || raise).index { |c| c.location == last_argument_nodes.fetch(-2).location }.to_i
            if method_type.type.rest_positionals
              [pos + 1, positionals - 1].min
            else
              [pos + 1, positionals].min
            end
          end
        else
          # Cursor is on the argument
          case argument_nodes.fetch(-2).type
          when :splat
            method_type.type.required_positionals.size + method_type.type.optional_positionals.size if method_type.type.rest_positionals
          when :kwargs
            if argument_nodes[-3]
              case argument_nodes.fetch(-3).type
              when :pair
                argname = argument_nodes.fetch(-3).children.first.children.first
                if method_type.type.required_keywords.key?(argname)
                  positionals + method_type.type.required_keywords.keys.index(argname).to_i
                elsif method_type.type.optional_keywords.key?(argname)
                  positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.keys.index(argname).to_i
                elsif method_type.type.rest_keywords
                  positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.size
                end
              when :kwsplat
                positionals + method_type.type.required_keywords.size + method_type.type.optional_keywords.size if method_type.type.rest_keywords
              end
            end
          else
            pos = (node.children[2...] || raise).index { |c| c.location == argument_nodes.fetch(-2).location }.to_i
            [pos, positionals - 1].min
          end
        end
      end
    end
  end
end
