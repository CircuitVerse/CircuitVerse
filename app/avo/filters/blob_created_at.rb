# frozen_string_literal: true

class Avo::Filters::BlobCreatedAt < Avo::Filters::DateTimeFilter
  self.name = "Created At"
  self.button_label = "Filter by Created Date"

  def apply(_request, query, value)
    return query if value.blank?

    time = Time.zone.parse(value.to_s)

    query.where(created_at: time.all_day)
  end
end
