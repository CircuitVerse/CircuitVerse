# frozen_string_literal: true

class TableRowComponent < ViewComponent::Base
  def initialize(assignment, current_user, group_and_policy, deadline_time)
    super
    @assignment = assignment
    @current_user = current_user
    @policy = group_and_policy[:policy]
    @deadline_minute = deadline_time[:minute]
    @deadline_day = deadline_time[:day]
    @deadline_year = deadline_time[:year]
    @deadline_second = deadline_time[:second]
    @deadline_hour = deadline_time[:hour]
    @deadline_month = deadline_time[:month]
    @group = group_and_policy[:group]
  end
end
