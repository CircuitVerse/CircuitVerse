# frozen_string_literal: true

class Avo::Filters::AssignmentByStatus < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(status: value)
  end

  def options
    # Fixed: Use distinct.pluck instead of pluck on distinct
    Assignment.pluck(:status).compact.uniq.sort.index_by(&:titleize)
  end
end
