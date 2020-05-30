# frozen_string_literal: true

module SortingHelper
  def self.sort_fields(sort, allowed)
    allowed = allowed.map(&:to_s)
    fields = sort.to_s.split(",")
    ordered_fields = ordered_hash(fields)
    ordered_fields.select { |key, _value| allowed.include?(key) }
  end

  def self.ordered_hash(fields)
    fields.each_with_object({}) do |field, hash|
      if field.start_with?("-")
        field = field[1..-1]
        hash[field] = :desc
      else
        hash[field] = :asc
      end
    end
  end
end
