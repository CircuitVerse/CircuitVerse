# frozen_string_literal: true

module AssignmentsHelper
  def deadline_year(assignment)
    assignment.deadline.strftime("%Y")
  end

  def deadline_month(assignment)
    assignment.deadline.strftime("%m")
  end

  def deadline_day(assignment)
    assignment.deadline.strftime("%-d")
  end

  def deadline_hour(assignment)
    assignment.deadline.strftime("%H")
  end

  def deadline_minute(assignment)
    assignment.deadline.strftime("%M")
  end

  def deadline_second(assignment)
    assignment.deadline.strftime("%S")
  end
end
