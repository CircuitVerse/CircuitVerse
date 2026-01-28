# frozen_string_literal: true

class Avo::Filters::GroupByMentor < Avo::Filters::SelectFilter
  self.name = "Mentor"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(primary_mentor_id: value)
  end

  def options
    User.where(admin: true).order(:name).pluck(:name, :id).to_h
  end
end
