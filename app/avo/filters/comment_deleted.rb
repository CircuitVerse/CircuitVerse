# frozen_string_literal: true

class Avo::Filters::CommentDeleted < Avo::Filters::SelectFilter
  self.name = "Deleted Status"

  def apply(_request, query, value)
    case value
    when "deleted"
      query.where.not(deleted_at: nil)
    when "active"
      query.where(deleted_at: nil)
    else
      query
    end
  end

  def options
    {
      deleted: "Deleted",
      active: "Active"
    }
  end
end
