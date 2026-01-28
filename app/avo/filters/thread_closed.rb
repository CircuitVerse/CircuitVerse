# frozen_string_literal: true

class Avo::Filters::ThreadClosed < Avo::Filters::SelectFilter
  self.name = "Thread Status"

  def apply(_request, query, value)
    case value
    when "closed"
      query.where.not(closed_at: nil)
    when "open"
      query.where(closed_at: nil)
    else
      query
    end
  end

  def options
    {
      closed: "Closed",
      open: "Open"
    }
  end
end
