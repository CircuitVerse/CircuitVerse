# frozen_string_literal: true

class Avo::Filters::VoteByUser < Avo::Filters::SelectFilter
  self.name = "User"

  def apply(_request, query, value)
    query.where(user_id: value)
  end

  def options
    User.order(:name).pluck(:name, :id).to_h
  end
end
