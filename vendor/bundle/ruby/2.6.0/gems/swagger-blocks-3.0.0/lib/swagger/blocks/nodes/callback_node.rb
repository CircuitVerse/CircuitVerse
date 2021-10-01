module Swagger
  module Blocks
    module Nodes
      class CallbackNode < Node
        def destination(address, inline_keys = nil, &block)
          self.data[address] = Swagger::Blocks::Nodes::CallbackDestinationNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
