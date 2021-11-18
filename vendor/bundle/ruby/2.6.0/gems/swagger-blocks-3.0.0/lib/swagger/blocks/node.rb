module Swagger
  module Blocks
    # Base node for representing every object in the Swagger DSL.
    class Node
      attr_accessor :name
      attr_writer :version
      VERSION_2 = '2.0'
      VERSION_3 = '3.0.0'

      def self.call(options = {}, &block)
        # Create a new instance and evaluate the block into it.
        instance = new
        instance.name = options[:name] if options[:name]
        instance.version = options[:version]
        instance.keys options[:inline_keys]
        instance.instance_eval(&block) if block
        instance
      end

      def as_json(options = {})
        version = options.fetch(:version, VERSION_2)

        result = {}
        self.data.each do |key, value|
          if value.is_a?(Node)
            result[key] = value.as_json(version: version)
          elsif value.is_a?(Array)
            result[key] = []
            value.each do |v|
              result[key] << value_as_json(v, version)
            end
          elsif value.is_a?(Hash)
            result[key] = {}
            value.each_pair {|k, v| result[key][k] = value_as_json(v, version) }
          elsif version == VERSION_2 && ref?(key) && !static_ref?(value)
            result[key] = "#/definitions/#{value}"
          elsif version == VERSION_3 && ref?(key) && self.is_a?(Swagger::Blocks::Nodes::LinkNode) && !static_ref?(value)
            result[key] = "#/components/links/#{value}"
          elsif version == VERSION_3 && ref?(key) && self.is_a?(Swagger::Blocks::Nodes::ExampleNode) && !static_ref?(value)
            result[key] = "#/components/examples/#{value}"
          elsif version == VERSION_3 && ref?(key) && self.is_a?(Swagger::Blocks::Nodes::ParameterNode) && !static_ref?(value)
            result[key] = "#/components/parameters/#{value}"
          elsif version == VERSION_3 && ref?(key) && self.is_a?(Swagger::Blocks::Nodes::RequestBodyNode) && !static_ref?(value)
            result[key] = "#/components/requestBodies/#{value}"
          elsif version == VERSION_3 && ref?(key) && self.is_a?(Swagger::Blocks::Nodes::ResponseNode) && !static_ref?(value)
            result[key] = "#/components/responses/#{value}"
          elsif version == VERSION_3 && ref?(key) && !static_ref?(value)
            result[key] = "#/components/schemas/#{value}"
          else
            result[key] = value
          end
        end
        return result if !name
        # If 'name' is given to this node, wrap the data with a root element with the given name.
        {name => result}
      end

      def ref?(key)
        key.to_s.eql?('$ref')
      end

      def static_ref?(value)
        value.to_s =~ %r{^#/|https?://}
      end

      def value_as_json(value, version)
        if value.respond_to?(:as_json)
           value.as_json(version: version)
        else
           value
        end
      end

      def data
        @data ||= {}
      end

      def keys(data)
        self.data.merge!(data) if data
      end

      def key(key, value)
        self.data[key] = value
      end

      def version
        return @version if instance_variable_defined?('@version') && @version
        return VERSION_2 if data.has_key?(:swagger) && data[:swagger] == VERSION_2
        return VERSION_3 if data.has_key?(:openapi) && data[:openapi] == VERSION_3
        raise DeclarationError, "You must specify swagger '#{VERSION_2}' or openapi '#{VERSION_3}'"
      end

      def is_swagger_2_0?
        version == VERSION_2
      end

      def is_openapi_3_0?
        version == VERSION_3
      end
    end
  end
end
