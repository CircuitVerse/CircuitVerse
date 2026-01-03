module Lookbook
  class TabPanels::Panel::Component < Lookbook::BaseComponent
    def initialize(name:, **html_attrs)
      @name = name
      super(**html_attrs)
    end
  end
end
