module Lookbook
  class SplitLayout::Component < Lookbook::BaseComponent
    renders_many :panes, Lookbook::TagComponent

    protected

    def alpine_component
      "splitLayoutComponent"
    end
  end
end
