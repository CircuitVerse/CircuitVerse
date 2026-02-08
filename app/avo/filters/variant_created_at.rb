# frozen_string_literal: true

class Avo::Filters::VariantCreatedAt < Avo::Filters::DateTimeFilter
  self.name = "Created At"

  def apply(_request, query, value)
    return query if value.blank?

    query = query.where(created_at: (value[:start_time])..) if value[:start_time].present?
    query = query.where(created_at: ..(value[:end_time])) if value[:end_time].present?
    query
  end
end
