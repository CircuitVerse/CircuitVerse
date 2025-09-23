module Lookbook
  class CopyButton::Component < Lookbook::BaseComponent
    attr_reader :icon, :size, :target, :button_attrs

    def initialize(target: nil, icon: :code, size: :md, **attrs)
      @icon = icon
      @size = size
      @target = target
      @button_attrs = attrs
    end

    def icon_size
      IconButton::Component::ICON_SIZES[size]
    end

    protected

    def alpine_data
      content ? nil : alpine_encode(target)
    end

    def alpine_component
      "copyButtonComponent"
    end
  end
end
