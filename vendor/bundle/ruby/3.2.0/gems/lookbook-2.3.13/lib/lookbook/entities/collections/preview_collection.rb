module Lookbook
  class PreviewCollection < EntityCollection
    include HierarchicalCollection

    TREE_BUILDER = PreviewTreeBuilder

    def find_scenario_by_path(lookup_path)
      scenarios.find_by_path(lookup_path)
    end

    def find_by_preview_class(klass)
      find { |preview| preview.preview_class.name == klass.to_s }
    end

    def load(code_objects, changes = nil)
      changes.present? ? reload_changed(code_objects, changes) : reload_all(code_objects)
    end

    def reload_all(code_objects)
      clear_all
      previews = code_objects.map { |obj| PreviewCollection.preview_from_code_object(obj) }.compact
      add(previews)
    end

    def reload_changed(code_objects, changes)
      modified = Array(changes[:modified])
      removed = Array(changes[:removed]) + modified
      added = Array(changes[:added]) + modified

      remove_by_file_path(removed)

      previews = added.map do |path|
        code_object = code_objects.find { |obj| obj if obj&.file.to_s == path.to_s }
        PreviewCollection.preview_from_code_object(code_object) if code_object
      end.compact

      add(previews)
    end

    def remove_by_file_path(paths)
      paths = Array(paths).map(&:to_s)
      @entities.reject! { |preview| preview.file_path.to_s.in?(paths) }
      clear_cache
    end

    def entities
      @_cache[:entities] ||= collect_ordered_entities(to_tree(include_hidden: true)).grep(Lookbook::PreviewEntity)
    end

    class << self
      def preview_from_code_object(code_object)
        klass = code_object.path.constantize
        if preview_class?(klass)
          preview = PreviewEntity.new(code_object)
          preview if preview.scenarios.any?
        end
      rescue => exception
        Lookbook.logger.error exception.to_s
        nil
      end

      def preview_class?(klass)
        if (defined?(ViewComponent) && klass.ancestors.include?(ViewComponent::Preview)) || klass.ancestors.include?(Lookbook::Preview)
          !klass.respond_to?(:abstract_class) || klass.abstract_class != true
        end
      end
    end

    protected

    def scenarios
      @_cache[:scenarios] ||= ScenarioCollection.new(flat_map(&:scenarios))
    end
  end
end
