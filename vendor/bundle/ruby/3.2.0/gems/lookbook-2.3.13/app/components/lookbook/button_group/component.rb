module Lookbook
  class ButtonGroup::Component < Lookbook::BaseComponent
    renders_many :buttons, ->(copy: nil, **attrs, &block) do
      attrs[:size] = @size
      if copy.present?
        lookbook_render :copy_button, target: copy, **attrs, &block
      else
        lookbook_render :button, **attrs, &block
      end
    end

    def initialize(size: :md, **html_attrs)
      @size = size
      super(**html_attrs)
    end
  end
end
