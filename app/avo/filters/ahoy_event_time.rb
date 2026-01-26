# frozen_string_literal: true

class Avo::Filters::AhoyEventTime < Avo::Filters::SelectFilter
  self.name = "Time"

  def apply(_request, query, value)
    case value
    when "today"
      query.where(time: Time.current.beginning_of_day..)
    when "yesterday"
      query.where(time: 1.day.ago.beginning_of_day...Time.current.beginning_of_day)
    when "last_7_days"
      query.where(time: 7.days.ago.beginning_of_day..)
    when "last_30_days"
      query.where(time: 30.days.ago.beginning_of_day..)
    when "last_90_days"
      query.where(time: 90.days.ago.beginning_of_day..)
    else
      query
    end
  end

  def options
    {
      today: "Today",
      yesterday: "Yesterday",
      last_7_days: "Last 7 days",
      last_30_days: "Last 30 days",
      last_90_days: "Last 90 days"
    }
  end
end
