# frozen_string_literal: true

class Avo::Filters::ProjectFeatured < Avo::Filters::BooleanFilter
  self.name = "Featured"

  def apply(_request, query, value)
    return query if value.blank?

    if value["featured"]
      query.joins(:featured_circuit)
    else
      query.where.missing(:featured_circuit)
    end
  end

  def options
    {
      featured: "Featured projects"
    }
  end
end
