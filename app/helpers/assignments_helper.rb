# frozen_string_literal: true

module AssignmentsHelper
  # @param [Assignment] assignment
  # @return [String] Deadline year
  def deadline_year(assignment)
    assignment.deadline.strftime("%Y")
  end

  # @param [Assignment] assignment
  # @return [String] Deadline month
  def deadline_month(assignment)
    assignment.deadline.strftime("%m")
  end

  # @param [Assignment] assignment
  # @return [String] Deadline day
  def deadline_day(assignment)
    assignment.deadline.strftime("%-d")
  end

  # @param [Assignment] assignment
  # @return [String] Deadline hour
  def deadline_hour(assignment)
    assignment.deadline.strftime("%H")
  end

  # @param [Assignment] assignment
  # @return [String] Deadline minute
  def deadline_minute(assignment)
    assignment.deadline.strftime("%M")
  end

  # @param [Assignment] assignment
  # @return [String] Deadline second
  def deadline_second(assignment)
    assignment.deadline.strftime("%S")
  end
end
