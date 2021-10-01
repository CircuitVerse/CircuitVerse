module Swagger
  module Blocks
    module Nodes
      class ExampleNode < Node
        def value(inline_keys = nil, &block)
          self.data[:value] = Swagger::Blocks::Nodes::ValueNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
