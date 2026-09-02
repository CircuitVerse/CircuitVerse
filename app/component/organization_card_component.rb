# frozen_string_literal: true

class OrganizationCardComponent < ViewComponent::Base
  DESCRIPTION_LENGTH = 150
  LOCATION_LENGTH = 20

  def initialize(organization:)
    super()
    @organization = organization
  end

  def truncated_description
    truncate(@organization.description, length: DESCRIPTION_LENGTH)
  end

  def truncated_location
    truncate(@organization.location, length: LOCATION_LENGTH)
  end

  def logo_fallback
    @organization.name.to_s.strip.first.to_s.upcase
  end
end
