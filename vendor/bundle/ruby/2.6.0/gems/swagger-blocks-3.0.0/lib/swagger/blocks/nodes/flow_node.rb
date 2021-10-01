module Swagger
  module Blocks
    module Nodes
      class FlowNode < Node
        def scopes(inline_keys = nil, &block)
          self.data[:scopes] = Swagger::Blocks::Nodes::ScopesNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
