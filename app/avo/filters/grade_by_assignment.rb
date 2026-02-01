# frozen_string_literal: true

class Avo::Filters::GradeByAssignment < Avo::Filters::SelectFilter
  self.name = "Assignment"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(assignment_id: value)
  end

  def options
    Assignment.order(:name).pluck(:name, :id).to_h
  end
end
