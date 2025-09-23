module Lookbook
  class Nav::Entity::Component < Nav::Item::Component
    ICONS = {
      page: :file,
      preview: :layers,
      scenario: :eye,
      scenario_group: :eye
    }.freeze

    def nav_icon
      ICONS[collapsed? ? :preview : node.type] || :file
    end

    def href
      if collapsed?
        node.first.url_path
      elsif type != :preview
        node.url_path
      end
    end

    def children
      collapsed? ? [] : super
    end

    def type
      collapsed? ? :scenario : node.type
    end

    def collapsed?
      node.type == :preview && node.children.one?
    end

    def search_terms
      matchers = if collapsed?
        node.first.search_terms
      else
        node.respond_to?(:search_terms) ? Array(node.search_terms) : []
      end
      matchers.flatten.map { |m| m.gsub(/\s/, "").downcase }
    end

    protected

    def alpine_data
      alpine_encode({id: node.id, matchers: search_terms})
    end
  end
end
