# frozen_string_literal: true

class SocialLinksComponentPreview < ViewComponent::Preview
  def default
    render(SocialLinksComponent.new)
  end
end
