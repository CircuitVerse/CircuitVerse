module Lookbook
  # Represents a group of preview scenarios within a preview class
  #
  # @api public
  class ScenarioGroupEntity < Entity
    include NavigableEntity

    # @!group Scenarios

    # Returns all scenarios within the group.
    #
    # @return [Array<ScenarioEntity>] All scenarios
    attr_reader :scenarios

    # @!endgroup

    # The preview that this scenario belongs to.
    #
    # @return [PreviewEntity] The parent preview entity
    attr_reader :preview

    # @api private
    alias_method :parent, :preview

    # @api private
    def initialize(name, scenarios, preview)
      @name = Utils.name(name)
      @scenarios = ScenarioCollection.new(scenarios)
      @preview = preview
      @lookup_path = "#{parent.lookup_path}/#{@name}"
    end

    # @!group Display options

    # Display options hash.
    #
    # Contains all display options defined via the `@display` tag
    # for each scenario in the group, merged with any globally-defined options.
    #
    # @return [Hash] The resolved display options
    def display_options
      merged = {}
      scenarios.to_a.reverse.map do |scenario|
        merged.merge!(scenario.display_options)
      end
      merged
    end

    # @!endgroup

    # @!group Render Targets

    # Collection of render targets (components or partials)
    # from each of the scenarios in the group.
    #
    # Render targets are guessed where possible (based on the preview class name)
    # but can also be manually specified using the `@renders` tag.
    #
    # @example :ruby
    #  "This group renders: #{group.render_targets.map(&:label).join(", ")}"
    #
    # @return [Array<RenderableEntity>] Render target entities
    def render_targets
      @_render_targets ||= RenderTargetCollection.new(scenarios.flat_map(&:render_targets).uniq(&:lookup_path))
    end

    alias_method :components, :render_targets

    # @!endgroup

    # @!group Annotations

    # Collection of tags from each of the scenarios in the group.
    # Can be filtered by tag name by providing the name as an argument.
    #
    # @example :ruby
    #   all_tags = group.tags
    #   display_tags = group.tags(:display)
    #
    # @param tag_name [Symbol] Optional tag type to filter by
    # @return [Array<YardTag>] Array of tags
    def tags(tag_name = nil)
      scenarios.flat_map { |scenario| scenario.tags(tag_name) }
    end

    # @api private
    def tag(tag_name = nil)
      tags(tag_name).first
    end

    # @!endgroup

    # @!group URLs

    # The inspector URL path for this scenario group
    #
    # @return [String] URL path
    def inspect_path
      lookbook_inspect_path(lookup_path)
    end

    # The standalone preview URL path for this scenario group
    #
    # @return [String] URL path
    def preview_path
      lookbook_preview_path(lookup_path)
    end

    alias_method :url_path, :inspect_path

    # @!endgroup

    # @!group Identity

    # Entity type identifier.
    # Returns `:scenario_group` for scenario groups.
    #
    # @return [Symbol] The entity type
    def type
      :scenario_group
    end

    # @!endgroup

    # @api private
    def search_terms
      [parent.search_terms, parent.label, label]
    end

    # @api private
    def add_scenario(scenario)
      @scenarios.add(scenario)
    end
  end
end
