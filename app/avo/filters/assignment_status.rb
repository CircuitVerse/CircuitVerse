# frozen_string_literal: true

class Avo::Filters::AssignmentStatus < Avo::Filters::SelectFilter
  self.name = "Assignment Status"

  def apply(_request, query, value)
    case value
    when "open"
      query.where(status: "open")
    when "closed"
      query.where(status: "closed")
    else
      query
    end
  end

  def options
    {
      open: "Open",
      closed: "Closed"
    }
  end
end
