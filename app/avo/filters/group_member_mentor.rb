# frozen_string_literal: true

class Avo::Filters::GroupMemberMentor < Avo::Filters::BooleanFilter
  self.name = "Mentor Status"

  def apply(_request, query, values)
    return query if values["mentor"].nil?

    query.where(mentor: values["mentor"])
  end

  def options
    {
      mentor: "Mentors Only"
    }
  end
end
