# frozen_string_literal: true

class Avo::Filters::ForumCategoryCreatedAt < Avo::Filters::DateTimeFilter
  self.name = "Created At"
  self.button_label = "Filter by Created Date"

  def apply(_request, query, value)
    return query if value.blank?

    start_time, end_time = extract_range(value)

    query = query.where(created_at: start_time..) if start_time.present?
    query = query.where(created_at: ..end_time) if end_time.present?
    query
  end

  private

    def parse_time(val)
      return val if val.is_a?(Time) || (defined?(ActiveSupport::TimeWithZone) && val.is_a?(ActiveSupport::TimeWithZone))

      begin
        Time.zone.parse(val.to_s)
      rescue StandardError
        nil
      end
    end

    def extract_range(value)
      if value.is_a?(String)
        parse_range_from_string(value)
      elsif value.is_a?(Hash)
        parse_range_from_hash(value)
      else
        [nil, nil]
      end
    end

    def parse_range_from_string(value)
      parts = value.split(/\s+to\s+/i, 2)
      start_time = parts[0].present? ? parse_time(parts[0]) : nil
      end_time = parts[1].present? ? parse_time(parts[1]) : nil

      [start_time, end_time]
    end

    def parse_range_from_hash(value)
      raw_start = value[:start_time] || value["start_time"] || value[:from] || value["from"]
      raw_end = value[:end_time] || value["end_time"] || value[:to] || value["to"]

      start_time = raw_start.present? ? parse_time(raw_start) : nil
      end_time = raw_end.present? ? parse_time(raw_end) : nil

      [start_time, end_time]
    end
end
