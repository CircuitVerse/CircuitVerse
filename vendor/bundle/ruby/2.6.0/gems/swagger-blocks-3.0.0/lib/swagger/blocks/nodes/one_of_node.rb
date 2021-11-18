module Swagger
  module Blocks
    module Nodes
      class OneOfNode < Node
        def items(inline_keys = nil, &block)
          self.data[:items] = Swagger::Blocks::Nodes::ItemsNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
