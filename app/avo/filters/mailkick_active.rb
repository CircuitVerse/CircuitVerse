# frozen_string_literal: true

class Avo::Filters::MailkickActive < Avo::Filters::SelectFilter
  self.name = "Active Status"

  def apply(_request, query, value)
    case value
    when "active"
      query.where(active: true)
    when "inactive"
      query.where(active: false)
    else
      query
    end
  end

  def options
    { active: "Active", inactive: "Inactive" }
  end
end
