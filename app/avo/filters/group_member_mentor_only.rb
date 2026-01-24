# frozen_string_literal: true

class Avo::Filters::GroupMemberMentorOnly < Avo::Filters::BooleanFilter
  self.name = "Member Type"

  def apply(_request, query, value)
    return query if value.blank?

    if value["mentors"]
      query.where(mentor: true)
    elsif value["students"]
      query.where(mentor: false)
    else
      query
    end
  end

  def options
    {
      mentors: "Mentors only",
      students: "Students only"
    }
  end
end
