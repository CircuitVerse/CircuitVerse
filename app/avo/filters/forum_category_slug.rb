# frozen_string_literal: true

class Avo::Filters::ForumCategorySlug < Avo::Filters::TextFilter
  self.name = "Slug"

  def apply(_request, query, value)
    return query if value.blank?

    query.where("slug ILIKE ?", "%#{value}%")
  end
end
