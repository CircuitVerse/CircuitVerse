# frozen_string_literal: true

class Avo::Filters::FeaturedCircuitByProject < Avo::Filters::SelectFilter
  self.name = "Project"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(project_id: value)
  end

  def options
    Project.where(project_access_type: "Public").order(:name).pluck(:name, :id).to_h
  end
end
