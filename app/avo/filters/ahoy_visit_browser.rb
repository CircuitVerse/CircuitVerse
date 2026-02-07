# frozen_string_literal: true

class Avo::Filters::AhoyVisitBrowser < Avo::Filters::SelectFilter
  self.name = "Browser"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(browser: value)
  end

  def options
    ::Ahoy::Visit.distinct.pluck(:browser).compact.sort.each_with_object({}) do |browser, hash|
      hash[browser] = browser
    end
  end
end
