module Lookbook
  class Icon::Component < Lookbook::BaseComponent
    ICON_CACHE = {}

    attr_reader :stroke

    def initialize(name:, size: 4, stroke: 2, **html_attrs)
      @icon_name = name.to_s.tr("_", "-")
      @size = size || 4
      @stroke = stroke
      super(**html_attrs)
    end

    def size_rems
      "#{@size * 0.25}rem"
    end
  end
end
