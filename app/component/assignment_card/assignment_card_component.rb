# frozen_string_literal: true

module AssignmentCard
  class AssignmentCardComponent < ViewComponent::Base
    include Pundit::Authorization
    include Devise::Controllers::Helpers

    def initialize(assignment, current_user, group, deadline_time)
      super
      @assignment = assignment
      @current_user = current_user
      @deadline_minute = deadline_time[:minute]
      @deadline_day = deadline_time[:day]
      @deadline_year = deadline_time[:year]
      @deadline_second = deadline_time[:second]
      @deadline_hour = deadline_time[:hour]
      @deadline_month = deadline_time[:month]
      @group = group
    end
  end
end
