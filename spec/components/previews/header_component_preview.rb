# frozen_string_literal: true

class HeaderComponentPreview < ViewComponent::Preview
  def default
    render(LayoutComponents::HeaderComponent.new)
  end
end
