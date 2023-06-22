# frozen_string_literal: true

class AssignmentDecorator < SimpleDelegator
  # @return [Assignment]
  def assignment
    __getobj__
  end

  # @return [String] Text of grade
  def graded
    assignment.graded? ? "Graded(#{assignment.grading_scale})" : "Not Graded"
  end

  # @return [String] Grade scale text
  def grading_scale_str
    case assignment.grading_scale
    when "letter"
      "Assignments can be graded with any of letters A/B/C/D/E/F"
    when "percent"
      "Assignments can be graded on a scale of 1-100"
    when "no_scale"
      "Assignment won't be graded"
    when "custom"
      "Assignment can be graded as required"
    end
  end

  # @return [String] Restricted elements JSON string
  def restricted_circuit_elements
    restricted_elements_str = JSON.parse(assignment.restrictions).reduce("") do |str, element|
      str += "#{element}, "
      str
    end

    restricted_elements_str.present? ? restricted_elements_str.slice(0..-3) : "None"
  end

  # @return [String] Restricted features string
  def restricted_features
    assignment.feature_restrictions.presence || "None"
  end

  # @return [Boolean] True if assignment is closed
  def closed?
    assignment.status == "closed"
  end

  # @return [String] Time remaining for assignment
  def time_remaining
    str = ""
    str += "#{(assignment.deadline.to_i - Time.current.to_i) / 1.day} days "
    str += "#{((assignment.deadline.to_i - Time.now.to_i) / 1.hour) % 24} hours"
    str += " #{((assignment.deadline.to_i - Time.now.to_i) / 1.minute) % 60} minutes"
    str
  end
end
