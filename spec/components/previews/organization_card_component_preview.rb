# frozen_string_literal: true

class OrganizationCardComponentPreview < ViewComponent::Preview
  def default
    render(OrganizationCardComponent.new(organization: sample_organization))
  end

  def minimal
    render(OrganizationCardComponent.new(organization: minimal_organization))
  end

  private

    def sample_organization
      org = Organization.new(
        name: "CircuitVerse Community",
        slug: "circuitverse-community",
        location: "Bengaluru, India",
        description: "A community platform for designing and simulating digital logic circuits."
      )
      def org.members_count = 42
      def org.to_param = "circuitverse-community"
      org
    end

    def minimal_organization
      org = Organization.new(name: "CircuitVerse Community", slug: "circuitverse-community")
      def org.members_count = 3
      def org.to_param = "circuitverse-community"
      org
    end
end
