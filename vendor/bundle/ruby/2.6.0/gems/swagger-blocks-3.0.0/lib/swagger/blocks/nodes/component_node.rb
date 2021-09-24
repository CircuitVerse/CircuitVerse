module Swagger
  module Blocks
    module Nodes
      class ComponentNode < Node
        def schema(name, inline_keys = nil, &block)
          self.data[:schemas] ||= {}
          schema_node = self.data[:schemas][name]

          if schema_node
            # Merge this schema_node declaration into the previous one
            schema_node.instance_eval(&block)
          else
            # First time we've seen this schema_node
            self.data[:schemas][name] = Swagger::Blocks::Nodes::SchemaNode.call(version: '3.0.0', inline_keys: inline_keys, &block)
          end
        end

        def link(name, inline_keys = nil, &block)
          self.data[:links] ||= {}
          self.data[:links][name] = Swagger::Blocks::Nodes::LinkNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def example(name, inline_keys = nil, &block)
          self.data[:examples] ||= {}
          self.data[:examples][name] = Swagger::Blocks::Nodes::ExampleNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def security_scheme(name, inline_keys = nil, &block)
          self.data[:securitySchemes] ||= {}
          self.data[:securitySchemes][name] = Swagger::Blocks::Nodes::SecuritySchemeNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def parameter(name, inline_keys = nil, &block)
          self.data[:parameters] ||= {}
          self.data[:parameters][name] = Swagger::Blocks::Nodes::ParameterNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def request_body(name, inline_keys = nil, &block)
          self.data[:requestBodies] ||= {}
          self.data[:requestBodies][name] = Swagger::Blocks::Nodes::RequestBodyNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def response(name, inline_keys = nil, &block)
          self.data[:responses] ||= {}
          self.data[:responses][name] = Swagger::Blocks::Nodes::ResponseNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
