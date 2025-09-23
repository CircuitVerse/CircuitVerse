module Lookbook
  class Button::Component < Lookbook::BaseComponent
    renders_one :dropdown

    attr_reader :id, :icon, :button_attrs

    def initialize(id: nil, icon: nil, **html_attrs)
      @id = id
      @icon = icon
      @button_attrs = html_attrs
    end

    def key
      Digest::SHA256.hexdigest(icon.to_s + dropdown.to_s + @button_attrs.to_json)
    end

    def dropdown?
      dropdown.present?
    end

    def text_button?
      content.present?
    end

    def icon_button?
      !text_button? && icon
    end

    def before_render
      if dropdown? && id.nil?
        raise "Dropdown buttons must be given an ID"
      end
    end

    def button_component
      icon_button? ? IconButton::Component : TextButton::Component
    end
  end
end
