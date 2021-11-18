module Swagger
  module Blocks
    module Nodes
      class PropertyNode < Node
        def items(inline_keys = nil, &block)
          self.data[:items] = Swagger::Blocks::Nodes::ItemsNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def property(name, inline_keys = nil, &block)
          self.data[:properties] ||= Swagger::Blocks::Nodes::PropertiesNode.new
          self.data[:properties].version = version
          self.data[:properties].property(name, inline_keys, &block)
        end

        def one_of(&block)
          self.data[:oneOf] ||= []
          self.data[:oneOf] << Swagger::Blocks::Nodes::OneOfNode.call(version: version, &block)
        end
      end
    end
  end
end
