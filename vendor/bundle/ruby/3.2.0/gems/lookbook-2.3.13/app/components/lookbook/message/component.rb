module Lookbook
  class Message::Component < Lookbook::BaseComponent
    attr_reader :title, :icon_name, :icon_position, :theme

    def initialize(title: nil, icon: nil, icon_position: :left, theme: :info, **html_attrs)
      @title = title
      @icon_name = icon
      @icon_position = icon_position
      @theme = theme
      super(**html_attrs)
    end
  end
end
