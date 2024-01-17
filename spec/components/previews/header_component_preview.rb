# frozen_string_literal: true

class HeaderComponentPreview < ViewComponent::Preview
  def component
    render(LayoutComponents::HeaderComponent.new)
  end
end
