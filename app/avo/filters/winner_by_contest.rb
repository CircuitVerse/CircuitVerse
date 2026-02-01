# frozen_string_literal: true

class Avo::Filters::WinnerByContest < Avo::Filters::SelectFilter
  self.name = "Contest"

  def apply(_request, query, value)
    query.where(contest_id: value)
  end

  def options
    Contest.pluck(:name, :id).to_h
  end
end
