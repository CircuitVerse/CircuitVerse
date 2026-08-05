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

    def cancel_path
      if organization.persisted?
        overview_organization_path(organization)
      else
        organizations_path
      end
    end
    def persisted_logo
      return unless organization.persisted?
      return unless organization.logo_attachment&.persisted?

      organization.logo
    end
end
