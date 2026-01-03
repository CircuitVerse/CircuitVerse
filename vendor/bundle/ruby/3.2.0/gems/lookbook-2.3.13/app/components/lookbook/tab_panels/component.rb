module Lookbook
  class TabPanels::Component < Lookbook::BaseComponent
    renders_many :panels, ->(**attrs) do
      @panel_counter += 1
      attrs[:name] ||= "tab-#{@panel_counter}"
      Lookbook::TabPanels::Panel::Component.new(**attrs)
    end

    def initialize(**html_attrs)
      @panel_counter = 0
      super
    end

    protected

    def alpine_component
      "tabPanelsComponent"
    end
  end
end
