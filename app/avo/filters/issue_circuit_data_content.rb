# frozen_string_literal: true

class Avo::Filters::IssueCircuitDataContent < Avo::Filters::SelectFilter
  self.name = "Data"

  def apply(_request, query, value)
    case value
    when "is_present"
      query.where.not(data: [nil, ""])
    when "is_blank"
      query.where(data: [nil, ""])
    when "contains_circuit"
      query.where("data LIKE ?", "%circuit%")
    when "contains_element"
      query.where("data LIKE ?", "%element%")
    else
      query
    end
  end

  def options
    {
      is_present: "Is present",
      is_blank: "Is blank",
      contains_circuit: "Contains 'circuit'",
      contains_element: "Contains 'element'"
    }
  end
end
