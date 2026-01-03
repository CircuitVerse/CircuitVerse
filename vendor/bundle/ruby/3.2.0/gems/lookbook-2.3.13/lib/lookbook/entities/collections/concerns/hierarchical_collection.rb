module Lookbook
  module HierarchicalCollection
    extend ActiveSupport::Concern

    TREE_BUILDER = nil

    included do
      def entities
        @_cache[:entities] ||= collect_ordered_entities(to_tree(include_hidden: true))
      end

      def to_tree(include_hidden: false)
        cache_key = include_hidden ? :tree_with_hidden : :tree
        @_cache[cache_key] ||= self.class::TREE_BUILDER.call(@entities, include_hidden: include_hidden)
      end

      protected

      def collect_ordered_entities(start_node)
        start_node.flat_map do |node|
          node_entity = node.content? ? [node.content] : []
          child_entities = collect_ordered_entities(node)
          [*node_entity, *child_entities]
        end
      end
    end
  end
end
