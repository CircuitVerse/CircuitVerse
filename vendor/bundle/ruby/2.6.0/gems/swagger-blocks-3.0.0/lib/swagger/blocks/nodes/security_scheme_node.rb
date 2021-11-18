module Swagger
  module Blocks
    module Nodes
      class SecuritySchemeNode < Node
        # TODO support ^x- Vendor Extensions

        def scopes(inline_keys = nil, &block)
          self.data[:scopes] = Swagger::Blocks::Nodes::ScopesNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def flow(name, inline_keys = nil, &block)
          self.data[:flows] ||= {}
          self.data[:flows][name] = Swagger::Blocks::Nodes::FlowNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
