module Lookbook
  class DimensionsDisplay::Component < Lookbook::BaseComponent
    def initialize(target:, **html_attrs)
      @target = target
      @alpine_data = alpine_encode(@target)
      super(**html_attrs)
    end

    protected

    def alpine_component
      "dimensionsDisplayComponent"
    end
  end
end
