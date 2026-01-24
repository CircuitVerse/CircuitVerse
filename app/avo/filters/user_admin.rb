# frozen_string_literal: true

class Avo::Filters::UserAdmin < Avo::Filters::BooleanFilter
  self.name = "User Type"

  def apply(_request, query, value)
    return query if value.blank?

    if value["admin"]
      query.where(admin: true)
    elsif value["non_admin"]
      query.where(admin: false)
    else
      query
    end
  end

  def options
    {
      admin: "Admins",
      non_admin: "Non-admins"
    }
  end
end
