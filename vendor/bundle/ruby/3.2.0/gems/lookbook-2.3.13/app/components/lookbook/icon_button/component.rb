module Lookbook
  class IconButton::Component < Lookbook::BaseComponent
    renders_many :icons, Lookbook::Icon::Component

    ICON_SIZES = {
      xs: 3,
      sm: 3.5,
      md: 4,
      lg: 6
    }

    attr_reader :icon, :tooltip, :disabled, :size, :href

    def initialize(id: nil, icon: nil, tooltip: nil, disabled: false, size: :md, href: nil, **html_attrs)
      @id = id
      @icon = icon
      @tooltip = tooltip
      @disabled = disabled
      @size = size
      @href = href
      super(**html_attrs)
    end

    def id
      @id ||= Utils.temp_id(prefix: "button")
    end

    def icon_size
      ICON_SIZES[size]
    end

    def padding
      [:xs, :sm].include?(size) ? "p-1" : "p-2"
    end

    def tag_name
      href.present? ? :a : :button
    end

    protected

    def alpine_component
      "buttonComponent"
    end
  end
end
