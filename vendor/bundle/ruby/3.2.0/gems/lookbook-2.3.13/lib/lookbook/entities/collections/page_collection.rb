module Lookbook
  class PageCollection < EntityCollection
    include HierarchicalCollection

    TREE_BUILDER = PageTreeBuilder

    def load(page_paths, changes = nil)
      file_paths = PageCollection.file_paths(page_paths)
      reload_all(file_paths) # TODO: Fix incremental reloading
      # changes.present? ? reload_changed(file_paths, changes) : reload_all(file_paths)
    end

    def reload_all(file_paths)
      clear_all
      add(pages_from_paths(file_paths))
    end

    def reload_changed(file_paths, changes)
      modified = Array(changes[:modified])
      removed = Array(changes[:removed]) + modified
      added = Array(changes[:added]) + modified

      remove_by_file_path(removed)
      add(pages_from_paths(added))
    end

    def remove_by_file_path(paths)
      paths = Array(paths).map(&:to_s)
      @entities.reject! { |page| page.file_path.to_s.in?(paths) }
      clear_cache
    end

    def pages_from_paths(file_paths)
      entities = file_paths.map { |path| PageCollection.entity(path) }
      pages, sections = entities.partition { |page| page.type == :page }

      page_dict = pages.index_by(&:lookup_path)
      sections.each do |section|
        parent = page_dict[section.lookup_path]
        section.parent = parent
        parent.add_section(section)
      end

      pages
    end

    def self.file_paths(directories)
      directories.flat_map do |dir|
        PathUtils.normalize_paths(Dir["#{dir}/**/*.html.*", "#{dir}/**/*.md.*", "#{dir}/**/*.md"].sort)
      end
    end

    def self.entity(file_path)
      File.basename(file_path).match?(%r{\[(.*?\w+)\]}) ? PageSectionEntity.new(file_path) : PageEntity.new(file_path)
    end
  end
end
