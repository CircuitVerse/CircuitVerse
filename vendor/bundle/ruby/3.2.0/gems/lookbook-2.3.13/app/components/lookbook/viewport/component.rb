module Lookbook
  class Viewport::Component < Lookbook::BaseComponent
    def initialize(src:, resize_height: true, resize_width: true, max_height: nil, iframe_id: nil, **html_attrs)
      @src = src
      @resize_height = resize_height
      @resize_width = resize_width
      @max_height = max_height
      @iframe_id = iframe_id
      super(**html_attrs)
    end

    protected

    def alpine_component
      "viewportComponent"
    end
  end
end
