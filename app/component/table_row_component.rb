# frozen_string_literal: true

class TableRowComponent < ViewComponent::Base
  def initialize(assignment, current_user, policy, deadline_minute, deadline_day, deadline_year, deadline_month, deadline_hour, deadline_second, group)
    super
    @assignment = assignment
    @current_user = current_user
    @policy = policy
    @deadline_minute = deadline_minute
    @deadline_day = deadline_day
    @deadline_year = deadline_year
    @deadline_second = deadline_second
    @deadline_hour = deadline_hour
    @deadline_month = deadline_month
    @group = group
  end
end
  