# frozen_string_literal: true

class OrganizationFormComponent < ViewComponent::Base
  def initialize(organization:)
    super()
    @organization = organization
  end

  private

    attr_reader :organization

    def existing_links
      return [] unless organization.links.is_a?(Array)

      organization.links.compact_blank
    end
end
