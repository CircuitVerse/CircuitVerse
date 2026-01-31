# frozen_string_literal: true

class Avo::Filters::CommentCreatedAt < Avo::Filters::DateTimeFilter
  self.name = "Created At"
  self.button_label = "Filter by Created Date"

  def apply(_request, query, value)
    return query if value.blank?

    start_time = value[:start_time]
    end_time = value[:end_time]

    query = query.where(created_at: start_time..) if start_time.present?
    query = query.where(created_at: ..end_time) if end_time.present?

    query
  end
end
