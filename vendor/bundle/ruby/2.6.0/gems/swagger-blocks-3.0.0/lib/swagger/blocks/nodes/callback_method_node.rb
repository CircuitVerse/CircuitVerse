module Swagger
  module Blocks
    module Nodes
      class CallbackMethodNode < Node
        def request_body(inline_keys = nil, &block)
          self.data[:requestBody] = Swagger::Blocks::Nodes::RequestBodyNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def response(resp, inline_keys = nil, &block)
          self.data[:responses] ||= {}
          self.data[:responses][resp] = Swagger::Blocks::Nodes::ResponseNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
