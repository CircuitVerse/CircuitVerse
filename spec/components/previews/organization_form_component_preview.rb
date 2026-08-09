# frozen_string_literal: true

class OrganizationFormComponentPreview < ViewComponent::Preview
  def default
    organization = Organization.new(
      name: "CircuitVerse Community",
      slug: "circuitverse-community",
      description: "A community platform for designing and simulating digital logic circuits.",
      location: "Bengaluru, India",
      links: [
        "https://github.com/CircuitVerse",
        "https://circuitverse.org"
      ]
    )
    render(OrganizationFormComponent.new(organization: organization))
  end
end
