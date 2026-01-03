module Lookbook
  # Represents a preview scenario method within a preview class
  #
  # @api public
  class ScenarioEntity < Entity
    include InspectableEntity
    include AnnotatableEntity
    include NavigableEntity

    delegate :group, to: :code_object

    # The preview that this scenario belongs to.
    #
    # @return [PreviewEntity] The parent preview entity
    attr_reader :preview

    # @api private
    alias_method :parent, :preview

    # @api private
    def initialize(code_object, preview, priority: nil)
      @code_object = code_object
      @preview = preview
      @default_priority = priority
      @lookup_path = "#{parent.lookup_path}/#{name}"
    end

    # @!group Identity

    # Human-readable unique scenario ID
    #
    # @return [String] The ID
    def id
      @_id ||= Utils.id(fetch_config(:id) { "#{parent.id}-#{code_object.name}" })
    end

    # Parameter-safe scenario name.
    #
    # @return [String] The name
    def name
      @_name ||= Utils.name(code_object.name)
    end

    # Entity type identifier.
    # Returns `:scenario` for scenarios.
    #
    # @return [Symbol] The entity type
    def type
      :scenario
    end

    # @!endgroup

    # @!group Display options

    # Display options hash.
    #
    # Contains all display options defined via the `@display` tag
    # merged with any globally-defined options.
    #
    # @return [Hash] The resolved display options
    def display_options
      parent.display_options.merge(fetch_config(:display_options, {}))
    end

    # @!endgroup

    # @!group Render Targets

    # @api private
    def render_targets
      @_render_targets ||= RenderTargetCollection.new(load_render_targets)
    end

    # @api private
    alias_method :components, :render_targets

    # The item (component or partial) that the scenario renders.
    #
    # The render target is guessed where possible (based on the preview class name)
    # but can also be manually specified using the `@renders` tag.
    #
    # @example :ruby
    #  "This scenario renders: #{scenario.render_target.label}"
    #
    # @return [RenderableEntity] The render target
    def render_target
      render_targets.first
    end

    alias_method :component, :render_target

    # @!endgroup

    # @!group URLs

    # The inspector URL path for this preview
    #
    # @return [String] URL path
    def inspect_path
      lookbook_inspect_path(lookup_path)
    end

    # The standalone preview URL path for this preview
    #
    # @return [String] URL path
    def preview_path
      lookbook_preview_path(lookup_path)
    end

    # @!endgroup

    # @api private
    def after_render_method
      fetch_config(:after_render) || parent.after_render_method
    end

    # @api private
    def scenarios
      [self]
    end

    # @api private
    def template_source(template_path)
      source_path = template_file_path(template_path)
      source_path ? File.read(source_path) : nil
    end

    # @api private
    def template_lang(template_path)
      path = template_file_path(template_path)
      Lookbook::Lang.guess(path) || Lookbook::Lang.find(:html)
    end

    # @api private
    def search_terms
      [parent.search_terms, parent.label, label]
    end

    alias_method :lang, :source_lang
    alias_method :examples, :scenarios
    alias_method :url_path, :inspect_path

    deprecate lang: :source_lang, deprecator: Deprecation
    deprecate examples: :scenarios, deprecator: Deprecation

    protected

    def sort_handler(other_entity)
      if Lookbook.config.preview_sort_scenarios
        label <=> other_entity.label
      else
        [priority, label] <=> [other_entity.priority, other_entity.label]
      end
    end

    def format_source(source)
      source.sub(/^def \w+\s?(\([^)]+\))?/m, "").split("\n")[0..-2].join("\n")
    end

    def template_file_path(template_path)
      return full_template_path(template_path) if respond_to?(:full_template_path, true)

      search_dirs = [*Engine.preview_paths, *Engine.view_paths]
      template_path = "#{template_path.to_s.sub(/\..*$/, "")}.html.*"
      PathUtils.determine_full_path(template_path, search_dirs)
    end

    def load_render_targets
      render_target_identifiers = [*fetch_config(:renders, []), *preview.send(:fetch_config, :renders, [])]
      render_target_identifiers = preview.guess_render_targets if render_target_identifiers.empty?

      render_targets = render_target_identifiers.map do |render_target|
        RenderableEntity.new(render_target)
      rescue Lookbook::Error, NameError
        Lookbook.logger.warn "#{render_target} was not found"
        nil
      end
      render_targets.compact.uniq(&:lookup_path)
    end
  end
end
