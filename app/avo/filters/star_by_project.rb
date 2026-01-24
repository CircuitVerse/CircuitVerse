# frozen_string_literal: true

class Avo::Filters::StarByProject < Avo::Filters::SelectFilter
  self.name = "Project"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(project_id: value)
  end

  def options
    Project.order(:name).pluck(:name, :id).to_h
  end
end
