module Swagger
  module Blocks
    module Nodes
      class AllOfNode < Node
        def as_json(options = {})
          version = options.fetch(:version, '2.0')
          result = []

          self.data.each do |value|
            if value.is_a?(Node)
              result << value.as_json(version: version)
            elsif value.is_a?(Array)
              r = []
              value.each { |v| r << value_as_json(v, version) }
              result << r
            elsif (is_swagger_2_0? || is_openapi_3_0?) && value.is_a?(Hash)
              r = {}
              value.each_pair {|k, v| r[k] = value_as_json(v, version) }
              result << r
            else
              result = value
            end
          end
          return result if !name
          # If 'name' is given to this node, wrap the data with a root element with the given name.
          {name => result}
        end

        def data
          @data ||= []
        end

        def key(key, value)
          raise NotSupportedError
        end

        def schema(inline_keys = nil, &block)
          data << Swagger::Blocks::Nodes::SchemaNode.call(version: version, inline_keys: inline_keys, &block)
        end
      end
    end
  end
end
