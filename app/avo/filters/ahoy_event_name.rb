# frozen_string_literal: true

class Avo::Filters::AhoyEventName < Avo::Filters::SelectFilter
  self.name = "Event Name"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(name: value)
  end

  def options
    ::Ahoy::Event.distinct.pluck(:name).compact.sort.each_with_object({}) do |name, hash|
      hash[name] = name
    end
  end
end
