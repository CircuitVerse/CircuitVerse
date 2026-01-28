# frozen_string_literal: true

class Avo::Filters::AssignmentByGradingScale < Avo::Filters::SelectFilter
  self.name = "Grading Scale"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(grading_scale: value)
  end

  def options
    {
      "No Scale" => "no_scale",
      "Letter (A-F)" => "letter",
      "Percent (0-100)" => "percent",
      "Custom" => "custom"
    }
  end
end
