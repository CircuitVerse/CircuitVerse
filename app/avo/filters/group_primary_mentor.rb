# frozen_string_literal: true

class Avo::Filters::GroupPrimaryMentor < Avo::Filters::BooleanFilter
  self.name = "Has Primary Mentor"

  def apply(request, query, values)
    return query unless values["has_mentor"]

    query.where.not(primary_mentor_id: nil)
  end

  def options
    {
      has_mentor: "Has Primary Mentor"
    }
  end
end
