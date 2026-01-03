module Lookbook
  class Embed::Inspector::Component < Lookbook::BaseComponent
    attr_reader :target, :context, :scenarios, :panels, :options, :actions

    def initialize(target:, context: nil, options: nil, scenarios: nil, panels: nil, actions: nil, **html_attrs)
      @target = target
      @context = context.to_h
      @options = options.to_h
      @panels = Array(panels)
      @actions = Array(actions).map(&:to_sym)
      @scenarios = Array(scenarios)
      super(**html_attrs)
    end

    def id
      Utils.id(
        "embed-inspector",
        "#{scenarios.map(&:name).join}#{options.to_json}#{actions.to_json}#{panels.to_json}".hash
      )
    end

    def data
      context.fetch(:data, Store.new)
    end

    def params
      context.fetch(:params, {}).to_h
    end

    def dynamic_display_options
      context.fetch(:dynamic_display_options, {}).to_h
    end

    def static_display_options
      context.fetch(:static_display_options, {}).to_h
    end

    def display_action?(name)
      actions.include?(name)
    end

    def scenario_select_options
      scenarios.map { |scenario| [scenario.label, helpers.lookbook_embed_path(scenario.lookup_path)] }
    end

    def display_option_controls?
      options.fetch(:display_option_controls, true)
    end

    def drawer?
      panels.any?
    end

    protected

    def alpine_data
      [alpine_encode(id), "$store.pages.embeds"].join(",")
    end

    def alpine_component
      "embedInspectorComponent"
    end
  end
end
