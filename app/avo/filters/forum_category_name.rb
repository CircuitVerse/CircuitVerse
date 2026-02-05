# frozen_string_literal: true

class Avo::Filters::ForumCategoryName < Avo::Filters::TextFilter
  self.name = "Name"

  def apply(_request, query, value)
    return query if value.blank?

    query.where("name ILIKE ?", "%#{value}%")
  end
end
