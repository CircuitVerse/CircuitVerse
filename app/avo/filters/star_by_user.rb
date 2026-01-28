# frozen_string_literal: true

class Avo::Filters::StarByUser < Avo::Filters::SelectFilter
  self.name = "User"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(user_id: value)
  end

  def options
    User.order(:name).pluck(:name, :id).to_h
  end
end
