module Lookbook
  class Logo::Component < Lookbook::BaseComponent
    attr_reader :stroke

    def initialize(size: 4, stroke: 2, **html_attrs)
      @size = size || 4
      @stroke = stroke
      super(**html_attrs)
    end

    def size_rems
      "#{@size * 0.25}rem"
    end
  end
end
