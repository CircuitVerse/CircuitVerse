module Swagger
  module Blocks
    module Nodes
      class ServerNode < Node
        def variable(name, inline_keys = nil, &block)
          self.data[:variables] ||= {}
          self.data[:variables][name] = Swagger::Blocks::Nodes::VariableNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
