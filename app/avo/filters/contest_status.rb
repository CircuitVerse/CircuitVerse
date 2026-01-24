# frozen_string_literal: true

class Avo::Filters::ContestStatus < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(_request, query, value)
    return query if value.blank?

    # Filter by the actual enum value
    query.where(status: value)
  end

  def options
    {
      "live" => "Live",
      "completed" => "Completed"
    }
  end
end
