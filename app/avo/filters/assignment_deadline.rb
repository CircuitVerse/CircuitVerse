# frozen_string_literal: true

class Avo::Filters::AssignmentDeadline < Avo::Filters::SelectFilter
  self.name = "Deadline Status"

  def apply(_request, query, value)
    case value
    when "upcoming"
      query.where(deadline: Time.zone.now..)
    when "overdue"
      query.where(deadline: ..Time.zone.now)
    when "this_week"
      query.where(deadline: Time.zone.now.all_week)
    when "this_month"
      query.where(deadline: Time.zone.now.all_month)
    else
      query
    end
  end

  def options
    {
      upcoming: "Upcoming",
      overdue: "Overdue",
      this_week: "This Week",
      this_month: "This Month"
    }
  end
end
