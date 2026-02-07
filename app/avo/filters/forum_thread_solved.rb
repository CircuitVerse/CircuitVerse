# frozen_string_literal: true

class Avo::Filters::ForumThreadSolved < Avo::Filters::SelectFilter
  self.name = "Solved"

  def apply(_request, query, value)
    return query if value.blank?

    case value
    when "solved"
      query.where(solved: true)
    when "unsolved"
      query.where(solved: false)
    else
      query
    end
  end

  def options
    { solved: "Solved", unsolved: "Unsolved" }
  end
end
