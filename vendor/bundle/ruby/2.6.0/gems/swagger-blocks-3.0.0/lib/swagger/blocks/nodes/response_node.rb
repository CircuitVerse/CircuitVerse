module Swagger
  module Blocks
    module Nodes
      # v2.0: https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#responseObject
      class ResponseNode < Node
        def schema(inline_keys = nil, &block)
          self.data[:schema] = Swagger::Blocks::Nodes::SchemaNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def header(head, inline_keys = nil, &block)
          # TODO validate 'head' is as per spec
          self.data[:headers] ||= {}
          self.data[:headers][head] = Swagger::Blocks::Nodes::HeaderNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def content(type, inline_keys = nil, &block)
          self.data[:content] ||= {}
          self.data[:content][type] = Swagger::Blocks::Nodes::ContentNode.call(version: version, inline_keys: inline_keys, &block)
        end

        def example(name = nil, inline_keys = nil, &block)
          if name.nil?
            self.data[:example] = Swagger::Blocks::Nodes::ExampleNode.call(version: version, inline_keys: inline_keys, &block)
          else
            self.data[:examples] ||= {}
            self.data[:examples][name] = Swagger::Blocks::Nodes::ExampleNode.call(version: version, inline_keys: inline_keys, &block)
          end
        end

        def link(name, inline_keys = nil, &block)
          self.data[:links] ||= {}
          self.data[:links][name] = Swagger::Blocks::Nodes::LinkNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
