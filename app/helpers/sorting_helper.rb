# frozen_string_literal: true

module SortingHelper
  # @param sort [String] the sort string specifying the fields to sort
  # @param allowed [Array<String>] the allowed fields for sorting
  # @return [Hash] a hash representing the ordered fields with their sort direction
  def self.sort_fields(sort, allowed)
    allowed = allowed.map(&:to_s)
    fields = sort.to_s.split(",")
    ordered_fields = ordered_hash(fields)
    ordered_fields.select { |key, _value| allowed.include?(key) }
  end

  # @param fields [Array<String>] the fields to sort
  # @return [Hash] a hash representing the ordered fields with their sort direction
  def self.ordered_hash(fields)
    fields.each_with_object({}) do |field, hash|
      if field.start_with?("-")
        field = field[1..]
        hash[field] = :desc
      else
        hash[field] = :asc
      end
    end
  end
end
