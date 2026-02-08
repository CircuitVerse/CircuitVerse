# frozen_string_literal: true

class Avo::Filters::AhoyEventDateRange < Avo::Filters::DateTimeFilter
  self.name = "Custom Date Range"
  self.button_label = "Filter by Date Range"

  def apply(_request, query, value)
    return query if value.blank?

    start_time = value[:start_time]
    end_time = value[:end_time]

    query = query.where(time: start_time..) if start_time.present?
    query = query.where(time: ..end_time) if end_time.present?

    query
  end
end
