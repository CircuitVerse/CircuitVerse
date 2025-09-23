module Lookbook
  class PageTabs::Component < Lookbook::BaseComponent
    renders_many :tabs, ->(**attrs, &block) do
      @tabs ||= []
      attrs[:tab_content] = capture(&block)
      attrs[:markdown] ||= @markdown
      @tabs << attrs
    end

    def initialize(markdown: true, **html_attrs)
      @markdown = markdown
      super(**html_attrs)
    end

    def before_render
      tabs.size
    end
  end
end
