module Lookbook
  class Embed::Component < Lookbook::BaseComponent
    ACTIONS = [:inspect, :open]

    attr_reader :preview, :scenario, :params, :options

    def initialize(scenario:, params: {}, options: {}, **html_attrs)
      @scenario = scenario
      @preview = scenario.preview
      @params = params.to_h
      @options = options.to_h
      super(**html_attrs)
    end

    def preview_class
      preview.preview_class.name
    end

    def panels
      options.fetch(:panels, []).map(&:to_s)
    end

    def actions
      options.fetch(:actions, ACTIONS).map(&:to_s)
    end

    def params_attrs_str
      params.map { |key, value| "param-#{key}=\"#{value}\"" }.join(" ").strip.html_safe
    end
  end
end
