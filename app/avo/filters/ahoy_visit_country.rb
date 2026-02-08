# frozen_string_literal: true

class Avo::Filters::AhoyVisitCountry < Avo::Filters::SelectFilter
  self.name = "Country"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(country: value)
  end

  def options
    ::Ahoy::Visit.distinct.pluck(:country).compact.sort.each_with_object({}) do |country, hash|
      hash[country] = country
    end
  end
end
