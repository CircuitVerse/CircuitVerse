module Swagger
  module Blocks
    module Nodes
      class CallbackDestinationNode < Node
        def method(method_name, inline_keys = nil, &block)
          self.data[method_name] = Swagger::Blocks::Nodes::CallbackMethodNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
