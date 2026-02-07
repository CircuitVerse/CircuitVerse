# frozen_string_literal: true

class Avo::Filters::ForumCategoryColor < Avo::Filters::TextFilter
  self.name = "Color"

  def apply(_request, query, value)
    return query if value.blank?

    query.where("color ILIKE ?", "%#{value}%")
  end
end
