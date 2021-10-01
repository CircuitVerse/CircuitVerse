module Swagger
  module Blocks
    module Nodes
      # v2.0: https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#operation-object
      class OperationNode < Node
        def parameter(inline_keys = nil, &block)
          inline_keys = {'$ref' => "#/parameters/#{inline_keys}"} if inline_keys.is_a?(Symbol)

          self.data[:parameters] ||= []
          self.data[:parameters] << Swagger::Blocks::Nodes::ParameterNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def response(resp, inline_keys = nil, &block)
          # TODO validate 'resp' is as per spec
          self.data[:responses] ||= {}
          self.data[:responses][resp] = Swagger::Blocks::Nodes::ResponseNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def externalDocs(inline_keys = nil, &block)
          self.data[:externalDocs] = Swagger::Blocks::Nodes::ExternalDocsNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def security(inline_keys = nil, &block)
          self.data[:security] ||= []
          self.data[:security] << Swagger::Blocks::Nodes::SecurityRequirementNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def request_body(inline_keys = nil, &block)
          self.data[:requestBody] = Swagger::Blocks::Nodes::RequestBodyNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def callback(event_name, inline_keys = nil, &block)
          self.data[:callbacks] ||= {}
          self.data[:callbacks][event_name] = Swagger::Blocks::Nodes::CallbackNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def server(inline_keys = nil, &block)
          raise NotSupportedError unless is_openapi_3_0?
          self.data[:servers] ||= []
          self.data[:servers] << Swagger::Blocks::Nodes::ServerNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
