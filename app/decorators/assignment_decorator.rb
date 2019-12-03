# frozen_string_literal: true

class AssignmentDecorator < SimpleDelegator
  def assignment
    __getobj__
  end

  def graded
    assignment.graded? ? "Graded(#{assignment.grading_scale})" : "Not Graded"
  end

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

  def restricted_circuit_elements
    restricted_elements_str = JSON.parse(assignment.restrictions).reduce("") do |str, element|
      str += "#{element}, "
      str
    end

    restricted_elements_str.present? ? restricted_elements_str.slice(0..-3) : "None"
  end
end
