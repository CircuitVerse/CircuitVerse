# frozen_string_literal: true

class OrganizationSocialLinksComponentPreview < ViewComponent::Preview
  def default
    render(
      OrganizationSocialLinksComponent.new(
        links: [
          "https://github.com/CircuitVerse",
          "https://www.linkedin.com/company/circuitverse",
          "https://www.youtube.com/@circuitverse-official",
          "https://www.instagram.com/circuitverseorg",
          "https://circuitverse.org"
        ]
      )
    )
  end
end
