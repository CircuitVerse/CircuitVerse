module Lookbook
  class InspectorPanel::Component < Lookbook::BaseComponent
    attr_reader :panel_styles, :panel_html

    def initialize(name:, **attrs)
      @name = name
      super(**attrs)
    end

    def id
      Utils.id("panel", @name)
    end

    def before_render
      styles, html = StylesExtractor.call(content)
      @panel_styles = styles.map { |s| "##{id} #{s}" }.join("\n")
      @panel_html = html.html_safe
    end
  end
end
