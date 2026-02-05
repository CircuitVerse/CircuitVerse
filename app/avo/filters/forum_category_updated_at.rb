# frozen_string_literal: true

class Avo::Filters::ForumCategoryUpdatedAt < Avo::Filters::DateTimeFilter
  self.name = "Updated At"
  self.button_label = "Filter by Updated Date"

  def apply(_request, query, value)
    return query if value.blank?

    start_time = nil
    end_time = nil

    if value.is_a?(String)
      parts = value.split(/\s+to\s+/i, 2)
      start_time = parse_time(parts[0]) if parts[0]&.present?
      end_time = parse_time(parts[1]) if parts[1]&.present?
    elsif value.is_a?(Hash)
      raw_start = value[:start_time] || value['start_time'] || value[:from] || value['from']
      raw_end = value[:end_time] || value['end_time'] || value[:to] || value['to']

      start_time = parse_time(raw_start) if raw_start.present?
      end_time = parse_time(raw_end) if raw_end.present?
    end

    query = query.where(updated_at: start_time..) if start_time.present?
    query = query.where(updated_at: ..end_time) if end_time.present?

    query
  end

  private

  def parse_time(val)
    return val if val.is_a?(Time) || defined?(ActiveSupport::TimeWithZone) && val.is_a?(ActiveSupport::TimeWithZone)
    Time.zone.parse(val.to_s) rescue nil
  end
end
