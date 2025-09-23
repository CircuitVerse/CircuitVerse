module Lookbook
  class Tabs::DropdownTab::Component < Lookbook::BaseComponent
    def initialize(name:, label: nil, hotkey: nil, disabled: nil, position: 0, theme: :toolbar, **html_attrs)
      @name = name
      @label = label
      @hotkey = hotkey
      @disabled = disabled
      @position = position
      @theme = theme
      super(**html_attrs)
    end

    def label
      @label.presence || content || @name.titleize
    end
  end
end
