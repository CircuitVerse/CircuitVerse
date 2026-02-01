# frozen_string_literal: true

class Avo::Filters::CommentUpdatedAt < Avo::Filters::DateTimeFilter
  self.name = "Updated At"
  self.button_label = "Filter by Updated Date"

  def apply(_request, query, value)
    return query if value.blank?

    start_time = value[:start_time]
    end_time = value[:end_time]

    query = query.where(updated_at: start_time..) if start_time.present?
    query = query.where(updated_at: ..end_time) if end_time.present?

    query
  end
end
