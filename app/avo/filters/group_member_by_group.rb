# frozen_string_literal: true

class Avo::Filters::GroupMemberByGroup < Avo::Filters::SelectFilter
  self.name = "Group"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(group_id: value)
  end

  def options
    Group.order(:name).pluck(:name, :id).to_h
  end
end
