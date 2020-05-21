# frozen_string_literal: true

module SortingHelper
  def self.sort_fields(sort, allowed)
    fields = sort.to_s.split(",")
    fields.select { |field| allowed.include?(field.start_with?("-") ? field[1..-1] : field) }
    fields.map { |field| field + (field.start_with?("-") ? " DESC" : " ASC") }
    fields.join(", ")
  end
end
