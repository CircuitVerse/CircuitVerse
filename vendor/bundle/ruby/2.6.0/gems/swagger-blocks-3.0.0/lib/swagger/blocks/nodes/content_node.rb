module Swagger
  module Blocks
    module Nodes
      class ContentNode < Node
        def schema(inline_keys = nil, &block)
          self.data[:schema] = Swagger::Blocks::Nodes::SchemaNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def example(name = nil, inline_keys = nil, &block)
          if name.nil?
            self.data[:example] = Swagger::Blocks::Nodes::ExampleNode.call(version: version, inline_keys: inline_keys, &block)
          else
            self.data[:examples] ||= {}
            self.data[:examples][name] = Swagger::Blocks::Nodes::ExampleNode.call(version: version, inline_keys: inline_keys, &block)
          end
        end
      end
    end
  end
end
