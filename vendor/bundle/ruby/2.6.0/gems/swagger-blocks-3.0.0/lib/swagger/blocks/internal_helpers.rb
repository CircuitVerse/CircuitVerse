module Swagger
  module Blocks
    module InternalHelpers
      # Return [root_node, api_node_map] from all of the given swaggered_classes.
      def self.parse_swaggered_classes(swaggered_classes)
        root_nodes = []

        api_node_map = {}
        models_nodes = []

        path_node_map = {}
        schema_node_map = {}
        component_node = nil

        swaggered_classes.each do |swaggered_class|
          next unless swaggered_class.respond_to?(:_swagger_nodes, true)
          swagger_nodes = swaggered_class.send(:_swagger_nodes)
          root_node = swagger_nodes[:root_node]
          root_nodes << root_node if root_node

          # 2.0
          if swagger_nodes[:path_node_map]
            path_node_map.merge!(swagger_nodes[:path_node_map])
          end
          if swagger_nodes[:schema_node_map]
            schema_node_map.merge!(swagger_nodes[:schema_node_map])
          end
          if swagger_nodes[:component_node]
            if component_node
              merge_components(component_node, swagger_nodes, :examples)
              merge_components(component_node, swagger_nodes, :links)
              merge_components(component_node, swagger_nodes, :parameters)
              merge_components(component_node, swagger_nodes, :requestBodies)
              merge_components(component_node, swagger_nodes, :responses)
              merge_components(component_node, swagger_nodes, :schemas)
              merge_components(component_node, swagger_nodes, :securitySchemes)
            else
              component_node = swagger_nodes[:component_node]
            end
          end
        end

        data = {root_node: self.limit_root_node(root_nodes)}

        if data[:root_node].is_swagger_2_0?
          data[:path_nodes] = path_node_map
          data[:schema_nodes] = schema_node_map
        elsif data[:root_node].is_openapi_3_0?
          data[:path_nodes] = path_node_map
          data[:component_node] = component_node
        else
          data[:api_node_map] = api_node_map
          data[:models_nodes] = models_nodes
        end
        data
      end

      def self.merge_components(component_node, swagger_nodes, key)
        component_node.data[key] ||= {}
        component_node.data[key].merge!(swagger_nodes[:component_node].data[key]) if swagger_nodes[:component_node].data[key]
      end

      # Make sure there is exactly one root_node and return it.
      # TODO should this merge the contents of the root nodes instead?
      def self.limit_root_node(root_nodes)
        if root_nodes.length == 0
          raise Swagger::Blocks::DeclarationError.new(
            'swagger_root must be declared')
        elsif root_nodes.length > 1
          raise Swagger::Blocks::DeclarationError.new(
            'Only one swagger_root declaration is allowed.')
        end
        root_nodes.first
      end
    end
  end
end
