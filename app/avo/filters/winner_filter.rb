# frozen_string_literal: true

class Avo::Filters::WinnerFilter < Avo::Filters::BooleanFilter
  self.name = "Winner Status"

  def apply(_request, query, value)
    if value["winners"]
      query.where(winner: true)
    elsif value["non_winners"]
      query.where(winner: false)
    else
      query
    end
  end

  def options
    {
      winners: "Winners only",
      non_winners: "Non-winners only"
    }
  end
end
