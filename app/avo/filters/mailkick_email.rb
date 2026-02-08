# frozen_string_literal: true

class Avo::Filters::MailkickEmail < Avo::Filters::TextFilter
  self.name = "Email"
  self.button_label = "Filter by Email"

  def apply(_request, query, value)
    return query if value.blank?

    query.where("email ILIKE ?", "%#{value}%")
  end
end
