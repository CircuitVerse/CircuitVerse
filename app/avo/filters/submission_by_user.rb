# frozen_string_literal: true

class Avo::Filters::SubmissionByUser < Avo::Filters::BooleanFilter
  self.name = "Has Winner"

  def apply(_request, query, value)
    return query if value.blank?

    if value["has_winner"]
      query.joins(:contest_winner)
    else
      query.where.missing(:contest_winner)
    end
  end

  def options
    {
      has_winner: "Has contest winner"
    }
  end
end
