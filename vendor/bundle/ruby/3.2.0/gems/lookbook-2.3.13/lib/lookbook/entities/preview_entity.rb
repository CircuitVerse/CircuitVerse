module Lookbook
  # Represents a preview class
  #
  # @api public
  class PreviewEntity < Entity
    include AnnotatableEntity
    include LocatableEntity
    include NavigableEntity

    delegate :after_render, :render_args, to: :preview_class

    # @api private
    attr_reader :preview_class

    # @api private
    def initialize(code_object)
      @code_object = code_object
      @preview_class = code_object.path.constantize
      @file_path = Pathname(code_object.file)
      @base_directories = Engine.preview_paths

      cleaned_path = preview_class.name.underscore.strip
        .gsub(/(_component_preview|_preview)(\..+)?$/, "")
        .gsub(/\/(component_preview|preview|component)(\..+)?$/, "")

      @lookup_path = PathUtils.to_lookup_path(cleaned_path)
    end

    # @!group Scenarios

    # Get all scenarios defined in the preview class.
    #
    # @example :ruby
    #   scenario_names = preview.scenarios.map(&:name)
    #
    # @return [Array<ScenarioEntity>] All scenarios for the preview
    def scenarios
      @_scenarios ||= ScenarioCollection.new(load_scenarios)
    end

    alias_method :examples, :scenarios
    deprecate examples: :scenarios, deprecator: Deprecation

    # Find a specific scenario by (i.e. method) name
    #
    # @example :ruby
    #   default_scenario_preview_path = preview.scenario(:default).preview_path
    #
    # @param scenario_name [Symbol, String] Name of the scenario
    # @return [ScenarioEntity] The matching scenario, if found
    # @return [nil] if no matching scenario was found
    def scenario(scenario_name)
      scenarios.find { |m| m.name == scenario_name.to_s }
    end

    alias_method :example, :scenario
    deprecate example: :scenario, deprecator: Deprecation

    # Get all scenarios defined in the preview class that
    # have not been hidden (by using the `@hidden` tag).
    #
    # @example :ruby
    #   visible_scenario_names = preview.visible_scenarios.map(&:name)
    #
    # @return [Array<ScenarioEntity>] All visible scenarios for the preview
    def visible_scenarios
      @_visible_scenarios ||= ScenarioCollection.new(scenarios.select(&:visible?))
    end

    # Get all scenarios defined in the preview class
    # that are hidden (using the `@hidden` tag) and so
    # will not show up in the navigation.
    #
    # @example :ruby
    #   hidden_scenario_names = preview.hidden_scenarios.map(&:name)
    #
    # @return [Array<ScenarioEntity>] All hidden scenarios for the preview
    def hidden_scenarios
      @_hidden_scenarios ||= ScenarioCollection.new(scenarios.select(&:hidden?))
    end

    # The scenario used when a preview is rendered
    # without explicity specifying a scenario.
    #
    # @example :ruby
    #   default_scenario_name = preview.default_scenario.name
    #
    # @return [ScenarioEntity] The default scenario for this preview
    def default_scenario
      visible_scenarios.first
    end

    # @!endgroup

    # @!group Render Targets

    # All 'render targets' (i.e. components or partials) that are known
    # to be rendered within the scenarios defined within this preview.
    #
    # Render targets are guessed where possible (based on the preview class name)
    # but can also be manually specified using the `@renders` tag.
    #
    # @example :ruby
    #  "This preview renders: #{preview.render_targets.map(&:label).join(", ")}"
    #
    # @return [Array<RenderableEntity>] All known render targets used in the preview
    def render_targets
      @_render_targets ||= RenderTargetCollection.new(scenarios.flat_map(&:render_targets).uniq(&:lookup_path))
    end

    alias_method :components, :render_targets

    # @api private
    def render_target
      render_targets.first
    end

    # @api private
    alias_method :component, :render_target

    # @!endgroup

    # @!group URLs

    # The inspector URL path for this preview
    #
    # @return [String] URL path
    def inspect_path
      lookbook_inspect_path(lookup_path)
    end

    alias_method :url_path, :inspect_path

    # The standalone preview URL path for this preview
    #
    # @return [String] URL path
    def preview_path
      lookbook_preview_path(lookup_path)
    end

    # @!endgroup

    # The name of the associated preview class
    #
    # @return [String] Class name
    def preview_class_name
      preview_class.name
    end

    # @api private
    def file_name_base
      @_file_name_slug ||= file_name(true).gsub(/(_component_preview|component_preview|_preview|preview|component)$/, "")
    end

    # @api private
    def display_options
      global_options = Lookbook.config.preview_display_options
      global_options.deep_merge(fetch_config(:display_options, {}))
    end

    # @api private
    def after_render_method
      fetch_config(:after_render)
    end

    # @api private
    def layout
      preview_class.instance_variable_get(:@layout)
    end

    # @api private
    def guess_render_targets
      [preview_class.name.chomp("Preview").constantize&.name]
    rescue
      []
    end

    protected

    def load_scenarios
      code_object.groups.any? ? grouped_scenario_entities : scenario_entities
    end

    def grouped_scenario_entities
      scenarios = []
      scenario_entities.each.with_index(1) do |entity, i|
        if entity.group.nil?
          entity.default_priority = i
          scenarios << entity
        else
          group_name = entity.group.presence || entity.parent.name.pluralize
          group = scenarios.find do |s|
            s.is_a?(ScenarioGroupEntity) && s.name == Utils.name(group_name)
          end

          if group
            group.add_scenario(entity)
          else
            group = ScenarioGroupEntity.new(group_name, [entity], self)
            group.default_priority = i
            scenarios << group
          end
        end
      end
      scenarios
    end

    def scenario_entities
      public_methods = preview_class.public_instance_methods(false)
      method_objects = code_object.meths.select { |m| public_methods.include?(m.name) }
      method_objects.map.with_index { |code_object, i| ScenarioEntity.new(code_object, self, priority: i) }
    end
  end
end
