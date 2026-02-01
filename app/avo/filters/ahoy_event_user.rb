# frozen_string_literal: true

class Avo::Filters::AhoyEventUser < Avo::Filters::BooleanFilter
  self.name = "User Status"

  def apply(_request, query, value)
    query = query.where.not(user_id: nil) if value["has_user"]

    query = query.where(user_id: nil) if value["no_user"]

    query
  end

  def options
    {
      has_user: "Has User",
      no_user: "Anonymous"
    }
  end
end
