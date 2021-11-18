module Swagger
  module Blocks
    module Nodes
      class LinkNode < Node
        def parameters(inline_keys = nil, &block)
          self.data[:parameters] ||= Swagger::Blocks::Nodes::LinkParameterNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
