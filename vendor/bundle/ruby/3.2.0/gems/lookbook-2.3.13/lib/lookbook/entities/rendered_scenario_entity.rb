module Lookbook
  # Represents a **rendered** preview scenario.
  #
  # Extends ScenarioEntity with an `output`
  # method that returns the rendered HTML output.
  #
  # See the [ScenarioEntity](./scenario_entity) docs for other available methods.
  #
  # @api public
  class RenderedScenarioEntity
    delegate_missing_to :scenario

    # @api private
    attr_reader :scenario

    # @api private
    def initialize(scenario, output, params)
      @scenario = scenario
      @params = params
      @output = output
    end

    # HTML output of the rendered scenario.
    #
    # @return [String] Rendered output
    attr_reader :output

    # 'Beautified' HTML output of the rendered scenario.
    #
    # @return [String] Rendered output
    def beautified_output
      @_beautified_output ||= CodeBeautifier.call(output)
    end

    # @api private
    def source
      has_custom_template? ? template_source(template) : scenario.source
    end

    # @api private
    def source_lang
      has_custom_template? ? template_lang(template) : scenario.source_lang
    end

    protected

    attr_reader :params

    def render_args
      @_render_args ||= preview.render_args(scenario.name, params: params)
    end

    def template
      render_args[:template]
    end

    def view?
      render_args[:type] == :view
    end

    def has_custom_template?
      !template.in?(system_templates) && !custom_source? && !view?
    end

    def system_templates
      ["view_components/preview", Lookbook.config.preview_template]
    end
  end
end
