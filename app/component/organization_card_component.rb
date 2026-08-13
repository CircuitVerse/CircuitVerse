# frozen_string_literal: true

class OrganizationCardComponent < ViewComponent::Base
  DESCRIPTION_LENGTH = 100

  def initialize(organization:)
    super()
    @organization = organization
  end

  def truncated_description
    truncate(@organization.description, length: DESCRIPTION_LENGTH)
  end

  def logo_fallback
    @organization.name.first.upcase
  end
end
